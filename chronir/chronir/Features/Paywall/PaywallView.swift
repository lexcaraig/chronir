import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @State private var selectedPlan: PlanOption = .annual
    @Environment(\.dismiss) private var dismiss

    enum PlanOption {
        case monthly, annual, lifetime
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
            ColorTokens.backgroundPrimary
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
                .foregroundStyle(ColorTokens.textSecondary)
                .frame(width: 30, height: 30)
                .background(ColorTokens.backgroundTertiary, in: .circle)
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
                .foregroundStyle(ColorTokens.primary)

            Text("Unlock Plus")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(ColorTokens.textPrimary)
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
                .foregroundStyle(ColorTokens.primary)
                .frame(width: 40, height: 40)
                .background(ColorTokens.primary.opacity(0.12), in: .circle)

            Text(title)
                .chronirFont(.bodyLarge)
                .foregroundStyle(ColorTokens.textPrimary)

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
            planRow(
                plan: .lifetime,
                label: "Lifetime",
                price: viewModel.plusLifetime?.displayPrice ?? "$49.99",
                badge: "One-Time"
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
                    .strokeBorder(ColorTokens.borderDefault, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(ColorTokens.primary)
                                .frame(width: 12, height: 12)
                        }
                    }

                Text(label)
                    .chronirFont(.bodyLarge)
                    .foregroundStyle(ColorTokens.textPrimary)

                if let badge {
                    ChronirBadge(badge, color: ColorTokens.primary)
                }

                Spacer()

                Text(price)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTokens.textPrimary)
            }
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.md)
            .background(
                isSelected ? ColorTokens.primary.opacity(0.08) : ColorTokens.surfaceCard,
                in: .rect(cornerRadius: GlassTokens.cardRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                    .stroke(isSelected ? ColorTokens.primary : ColorTokens.borderDefault, lineWidth: isSelected ? 2 : 0.5)
            )
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: SpacingTokens.sm) {
            Text(renewalTermsText)
                .chronirFont(.caption)
                .foregroundStyle(ColorTokens.textTertiary)
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
                .background(ColorTokens.primary, in: Capsule())
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
                    .chronirFont(.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }

            Spacer()

            HStack(spacing: 4) {
                Link("Terms", destination: termsURL)
                Text("&").foregroundStyle(ColorTokens.textTertiary)
                Link("Privacy", destination: privacyURL)
            }
            .chronirFont(.caption)
            .foregroundStyle(ColorTokens.textTertiary)
        }
    }

    // MARK: - Helpers

    private var renewalTermsText: String {
        switch selectedPlan {
        case .monthly:
            let price = viewModel.plusMonthly?.displayPrice ?? "$1.99"
            return "Auto-renews at \(price)/month. "
                + "Cancel anytime in Settings > Apple ID > Subscriptions."
        case .annual:
            let price = viewModel.plusAnnual?.displayPrice ?? "$19.99"
            return "Auto-renews at \(price)/year. "
                + "Cancel anytime in Settings > Apple ID > Subscriptions."
        case .lifetime:
            return "One-time purchase. No subscription, no renewals — yours forever."
        }
    }

    private var purchaseButtonTitle: String {
        switch selectedPlan {
        case .monthly:
            let p = viewModel.plusMonthly?.displayPrice ?? "$1.99"
            return "Subscribe — \(p)/mo"
        case .annual:
            let p = viewModel.plusAnnual?.displayPrice ?? "$19.99"
            return "Subscribe — \(p)/yr"
        case .lifetime:
            let p = viewModel.plusLifetime?.displayPrice ?? "$49.99"
            return "Buy Once — \(p)"
        }
    }

    private func purchaseSelected() async {
        let product: StoreKit.Product?
        switch selectedPlan {
        case .monthly: product = viewModel.plusMonthly
        case .annual: product = viewModel.plusAnnual
        case .lifetime: product = viewModel.plusLifetime
        }
        guard let product else { return }
        await viewModel.purchase(product)
    }

    // swiftlint:disable:next force_unwrapping
    private let termsURL = URL(string: "https://gist.github.com/lexcaraig/88de245f9c109c4936efa515a3fb0b28")!
    // swiftlint:disable:next force_unwrapping
    private let privacyURL = URL(string: "https://gist.github.com/lexcaraig/88de245f9c109c4936efa515a3fb0b28")!
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
