import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @State private var selectedPlan: PlanOption = .annual
    @Environment(\.dismiss) private var dismiss

    enum PlanOption {
        case monthly, annual
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: SpacingTokens.xl) {
                    header
                    featureList
                    planSelector
                    ctaSection
                    legalFooter
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, 40)
            }

            closeButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ColorTokens.backgroundGradient
                .ignoresSafeArea()
        }
        .task {
            await viewModel.loadSubscriptionStatus()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.currentTier) {
            if !viewModel.isFreeTier { dismiss() }
        }
    }

    // MARK: - Close

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 30, height: 30)
                .chronirGlassCircle()
        }
        .padding(.top, 60)
        .padding(.trailing, SpacingTokens.lg)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: SpacingTokens.sm) {
            Spacer().frame(height: 80)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)
                .shadow(color: ColorTokens.primary.opacity(0.5), radius: 24)

            Text("Unlock Plus")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Features

    private var featureList: some View {
        VStack(spacing: SpacingTokens.md) {
            featureRow(icon: "infinity", title: "Unlimited alarms")
            featureRow(icon: "clock.badge.checkmark", title: "Custom snooze intervals")
            featureRow(icon: "bell.and.waves.left.and.right", title: "Pre-alarm warnings")
            featureRow(icon: "photo", title: "Photo attachments")
            featureRow(icon: "chart.bar", title: "Completion history & streaks")
        }
    }

    private func featureRow(icon: String, title: String) -> some View {
        HStack(spacing: SpacingTokens.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 40, height: 40)
                .chronirGlassCircle()

            Text(title)
                .font(TypographyTokens.bodyLarge)
                .foregroundStyle(.white)

            Spacer()
        }
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        VStack(spacing: SpacingTokens.sm) {
            planRow(
                plan: .annual,
                label: "Annual",
                price: viewModel.plusAnnual?.displayPrice ?? "$19.99",
                badge: "Best Deal"
            )
            planRow(
                plan: .monthly,
                label: "Monthly",
                price: viewModel.plusMonthly?.displayPrice ?? "$1.99",
                badge: nil
            )
        }
    }

    private func planRow(
        plan: PlanOption,
        label: String,
        price: String,
        badge: String?
    ) -> some View {
        let isSelected = selectedPlan == plan

        return Button { selectedPlan = plan } label: {
            HStack(spacing: SpacingTokens.md) {
                Circle()
                    .strokeBorder(.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(.white)
                                .frame(width: 12, height: 12)
                        }
                    }

                Text(label)
                    .font(TypographyTokens.bodyLarge)
                    .foregroundStyle(.white)

                if let badge {
                    Text(badge)
                        .font(TypographyTokens.labelSmall)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .chronirGlassCapsule()
                }

                Spacer()

                Text(price)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.md)
            .glassEffect(
                isSelected
                    ? GlassTokens.card.tint(ColorTokens.primary).interactive()
                    : GlassTokens.card,
                in: .rect(cornerRadius: GlassTokens.cardRadius)
            )
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: SpacingTokens.sm) {
            Text(renewalTermsText)
                .font(TypographyTokens.caption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            Button {
                Task { await purchaseSelected() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(purchaseButtonTitle)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.25, blue: 0.95),
                            Color(red: 0.5, green: 0.2, blue: 0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
            }
            .disabled(viewModel.isLoading)
        }
    }

    // MARK: - Legal Footer

    private var legalFooter: some View {
        HStack(spacing: 0) {
            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(TypographyTokens.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            HStack(spacing: 4) {
                Link("Terms", destination: termsURL)
                Text("&").foregroundStyle(.white.opacity(0.45))
                Link("Privacy", destination: privacyURL)
            }
            .font(TypographyTokens.caption)
            .foregroundStyle(.white.opacity(0.45))
        }
    }

    // MARK: - Helpers

    private var renewalTermsText: String {
        let price: String
        let period: String
        switch selectedPlan {
        case .monthly:
            price = viewModel.plusMonthly?.displayPrice ?? "$1.99"
            period = "month"
        case .annual:
            price = viewModel.plusAnnual?.displayPrice ?? "$19.99"
            period = "year"
        }
        return "Auto-renews at \(price)/\(period). "
            + "Cancel anytime in Settings > Apple ID > Subscriptions."
    }

    private var purchaseButtonTitle: String {
        switch selectedPlan {
        case .monthly:
            let p = viewModel.plusMonthly?.displayPrice ?? "$1.99"
            return "Subscribe — \(p)/mo"
        case .annual:
            let p = viewModel.plusAnnual?.displayPrice ?? "$19.99"
            return "Subscribe — \(p)/yr"
        }
    }

    private func purchaseSelected() async {
        let product: StoreKit.Product?
        switch selectedPlan {
        case .monthly: product = viewModel.plusMonthly
        case .annual: product = viewModel.plusAnnual
        }
        guard let product else { return }
        await viewModel.purchase(product)
    }

    // swiftlint:disable:next force_unwrapping
    private let termsURL = URL(string: "https://chronir.app/terms")!
    // swiftlint:disable:next force_unwrapping
    private let privacyURL = URL(string: "https://chronir.app/privacy")!
}

#Preview {
    PaywallView()
}
