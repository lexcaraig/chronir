import SwiftUI
import StoreKit

/// Chronir Plus paywall. Present it as a `fullScreenCover`; it brings its own `NavigationStack` with a
/// toolbar Close button, so don't push it onto another stack.
struct PaywallView: View {
    /// The Plus feature the user just tapped (e.g. a locked sound). It is listed first and explained.
    var highlight: PlusFeature?

    @State private var viewModel = PaywallViewModel()
    @State private var selectedPlan: PlanOption = .annual
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = 40
    @ScaledMetric(relativeTo: .body) private var radioSize: CGFloat = 24

    init(highlight: PlusFeature? = nil) {
        self.highlight = highlight
    }

    enum PlanOption {
        case monthly, annual
        // case lifetime — commented out until pricing is finalized

        var label: String { self == .annual ? "Annual" : "Monthly" }
        var period: String { self == .annual ? "year" : "month" }
        var shortPeriod: String { self == .annual ? "yr" : "mo" }
        var badge: String? { self == .annual ? "Best Deal" : nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpacingTokens.xl) {
                    header
                    featureList
                    planSection
                    ctaSection
                    legalFooter
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xl)
            }
            .scrollIndicators(.hidden)
            .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .task {
            await viewModel.loadSubscriptionStatus()
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.alert != nil },
                set: { if !$0 { viewModel.alert = nil } }
            ),
            presenting: viewModel.alert
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { alert in
            Text(alert.message)
        }
        .onChange(of: viewModel.currentTier) {
            if !viewModel.isFreeTier { dismiss() }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: SpacingTokens.sm) {
            Image(systemName: "bell.badge.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(ColorTokens.primary)
                .accessibilityHidden(true)

            Text("Never miss the once-a-year ones")
                .chronirFont(.headlineLarge)
                .foregroundStyle(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Chronir Plus gives every bill, refill, and renewal the urgency of a wake-up alarm.")
                .chronirFont(.bodyLarge)
                .foregroundStyle(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, SpacingTokens.md)
    }

    // MARK: - Features

    private var featureList: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            ForEach(PlusFeature.ordered(highlighting: highlight)) { feature in
                featureRow(feature, isHighlighted: feature == highlight)
            }
        }
    }

    private func featureRow(_ feature: PlusFeature, isHighlighted: Bool) -> some View {
        HStack(spacing: SpacingTokens.md) {
            Image(systemName: feature.iconName)
                .font(.body.weight(.medium))
                .foregroundStyle(ColorTokens.primary)
                .frame(width: featureIconSize, height: featureIconSize)
                .background(ColorTokens.primary.opacity(0.12), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                Text(feature.title)
                    .chronirFont(isHighlighted ? .titleSmall : .bodyLarge)
                    .foregroundStyle(ColorTokens.textPrimary)
                if isHighlighted {
                    Text(feature.benefit)
                        .chronirFont(.bodyMedium)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Plan Selector

    @ViewBuilder
    private var planSection: some View {
        switch viewModel.productLoadState {
        case .loading:
            VStack(spacing: SpacingTokens.sm) {
                placeholderPlanRow(label: "Annual")
                placeholderPlanRow(label: "Monthly")
            }
            .redacted(reason: .placeholder)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading plans")
        case .failed:
            loadFailedState
        case .loaded:
            VStack(spacing: SpacingTokens.sm) {
                if let annual = viewModel.plusAnnual {
                    planRow(
                        .annual,
                        price: annual.displayPrice,
                        detail: annualDetail(annual: annual, monthly: viewModel.plusMonthly)
                    )
                }
                if let monthly = viewModel.plusMonthly {
                    planRow(.monthly, price: monthly.displayPrice, detail: "Billed monthly")
                }
                // Lifetime plan commented out until pricing is finalized
            }
        }
    }

    private var loadFailedState: some View {
        VStack(spacing: SpacingTokens.md) {
            Image(systemName: "wifi.exclamationmark")
                .font(.title2)
                .foregroundStyle(ColorTokens.textSecondary)
                .accessibilityHidden(true)
            Text("Couldn't reach the App Store")
                .chronirFont(.titleSmall)
                .foregroundStyle(ColorTokens.textPrimary)
            Text("Plans and prices load from the App Store. Check your connection and try again.")
                .chronirFont(.bodyMedium)
                .foregroundStyle(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
            ChronirButton("Try Again", style: .secondary) {
                Task { await viewModel.loadProducts() }
            }
        }
        .padding(SpacingTokens.lg)
        .frame(maxWidth: .infinity)
        .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: GlassTokens.cardRadius))
    }

    private func placeholderPlanRow(label: String) -> some View {
        HStack(spacing: SpacingTokens.md) {
            radioIndicator(isSelected: false)
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                Text(label).chronirFont(.bodyLarge)
                Text("Billed every period").chronirFont(.bodyMedium)
            }
            Spacer()
            Text("$00.00").chronirFont(.titleMedium)
        }
        .foregroundStyle(ColorTokens.textPrimary)
        .padding(SpacingTokens.md)
        .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: GlassTokens.cardRadius))
    }

    private func planRow(_ plan: PlanOption, price: String, detail: String) -> some View {
        let isSelected = selectedPlan == plan

        return Button { selectedPlan = plan } label: {
            HStack(spacing: SpacingTokens.md) {
                radioIndicator(isSelected: isSelected)

                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    HStack(spacing: SpacingTokens.sm) {
                        Text(plan.label)
                            .chronirFont(.bodyLarge)
                            .foregroundStyle(ColorTokens.textPrimary)
                        if let badge = plan.badge {
                            planBadge(badge)
                        }
                    }
                    Text(detail)
                        .chronirFont(.bodyMedium)
                        .foregroundStyle(ColorTokens.textSecondary)
                }

                Spacer(minLength: SpacingTokens.sm)

                Text("\(price)/\(plan.shortPeriod)")
                    .chronirFont(.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorTokens.textPrimary)
            }
            .padding(SpacingTokens.md)
            .background(
                isSelected ? ColorTokens.primary.opacity(0.08) : ColorTokens.surfaceCard,
                in: .rect(cornerRadius: GlassTokens.cardRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                    .stroke(
                        isSelected ? ColorTokens.primary : ColorTokens.borderDefault,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .contentShape(.rect(cornerRadius: GlassTokens.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            [plan.label, "\(price) per \(plan.period)", detail, plan.badge].compactMap { $0 }.joined(separator: ", ")
        )
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func radioIndicator(isSelected: Bool) -> some View {
        Circle()
            .strokeBorder(isSelected ? ColorTokens.primary : ColorTokens.borderDefault, lineWidth: 2)
            .frame(width: radioSize, height: radioSize)
            .overlay {
                if isSelected {
                    Circle()
                        .fill(ColorTokens.primary)
                        .frame(width: radioSize / 2, height: radioSize / 2)
                }
            }
    }

    /// onPrimary on primary passes contrast in both appearances (ChronirBadge's white text does not in dark).
    private func planBadge(_ text: String) -> some View {
        Text(text)
            .chronirFont(.labelSmall)
            .foregroundStyle(ColorTokens.onPrimary)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xxs)
            .background(ColorTokens.primary, in: Capsule())
    }

    /// "$1.66/mo · Save 16%", computed from the real StoreKit prices.
    private func annualDetail(annual: Product, monthly: Product?) -> String {
        let perMonth = PlanPricing.monthlyEquivalent(annual: annual.price).formatted(annual.priceFormatStyle)
        guard let monthly,
              let savings = PlanPricing.savingsPercent(monthly: monthly.price, annual: annual.price) else {
            return "\(perMonth)/mo, billed yearly"
        }
        return "\(perMonth)/mo \u{00B7} Save \(savings)%"
    }

}

// MARK: - CTA, legal footer, purchase

private extension PaywallView {

    var ctaSection: some View {
        VStack(spacing: SpacingTokens.md) {
            if let renewalTermsText {
                Text(renewalTermsText)
                    .font(.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                Task { await purchaseSelected() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView().tint(ColorTokens.onPrimary)
                    } else {
                        Text(purchaseButtonTitle)
                            .chronirFont(.titleSmall)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundStyle(ColorTokens.onPrimary)
                .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget + SpacingTokens.sm)
                .padding(.vertical, SpacingTokens.xs)
                .background(ColorTokens.primary, in: Capsule())
                .opacity(canPurchase ? 1 : 0.5)
            }
            .buttonStyle(.plain)
            .disabled(!canPurchase)
        }
    }

    var canPurchase: Bool {
        viewModel.productLoadState == .loaded && !viewModel.isLoading
    }

    // MARK: - Legal Footer

    var legalFooter: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SpacingTokens.md) { legalLinks }
            VStack(spacing: 0) { legalLinks }
        }
        .font(.footnote)
        .tint(ColorTokens.primary)
    }

    @ViewBuilder
    var legalLinks: some View {
        Button("Restore Purchases") {
            Task { await viewModel.restorePurchases() }
        }
        .disabled(viewModel.isLoading)
        .frame(minHeight: SpacingTokens.touchMinTarget)
        .contentShape(.rect)

        Link("Terms of Use", destination: termsURL)
            .frame(minHeight: SpacingTokens.touchMinTarget)
            .contentShape(.rect)

        Link("Privacy Policy", destination: privacyURL)
            .frame(minHeight: SpacingTokens.touchMinTarget)
            .contentShape(.rect)
    }

    // MARK: - Helpers

    /// Guideline 3.1.2 disclosure. Only shown with a real StoreKit price.
    var renewalTermsText: String? {
        switch selectedPlan {
        case .monthly:
            guard let price = viewModel.plusMonthly?.displayPrice else { return nil }
            return "Auto-renews at \(price)/month until canceled. "
                + "Cancel anytime in Settings > Apple ID > Subscriptions at least 24 hours before renewal."
        case .annual:
            guard let price = viewModel.plusAnnual?.displayPrice else { return nil }
            return "Auto-renews at \(price)/year until canceled. "
                + "Cancel anytime in Settings > Apple ID > Subscriptions at least 24 hours before renewal."
        }
    }

    var purchaseButtonTitle: String {
        switch selectedPlan {
        case .monthly:
            guard let price = viewModel.plusMonthly?.displayPrice else { return "Subscribe" }
            return "Subscribe \u{2014} \(price)/mo"
        case .annual:
            guard let price = viewModel.plusAnnual?.displayPrice else { return "Subscribe" }
            return "Subscribe \u{2014} \(price)/yr"
        }
    }

    func purchaseSelected() async {
        switch selectedPlan {
        case .monthly: await viewModel.purchase(viewModel.plusMonthly)
        case .annual: await viewModel.purchase(viewModel.plusAnnual)
        }
    }

    // swiftlint:disable:next force_unwrapping
    var termsURL: URL { URL(string: "https://gist.github.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9")! }
    // swiftlint:disable:next force_unwrapping
    var privacyURL: URL { URL(string: "https://gist.github.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c")! }
}

#Preview("Light") {
    PaywallView()
        .environment(\.chronirTheme, .light)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PaywallView()
        .environment(\.chronirTheme, .dark)
        .preferredColorScheme(.dark)
}

#Preview("Highlight: Sounds") {
    PaywallView(highlight: .sounds)
        .preferredColorScheme(.dark)
}
