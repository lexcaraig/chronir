import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    private let subscriptionService = SubscriptionService.shared
    /// Shares restore + error messaging with the paywall.
    @State private var viewModel = PaywallViewModel()
    @State private var showPaywall = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            currentPlanSection
            planComparisonSection
            actionsSection
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Subscription")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
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
        .task {
            await subscriptionService.updateSubscriptionStatus()
        }
    }

    // MARK: - Current Plan

    private var currentPlanSection: some View {
        Section {
            HStack {
                ChronirText("Current Plan", style: .bodyPrimary)
                Spacer()
                ChronirBadge(
                    subscriptionService.currentTier.displayName,
                    color: badgeColor(for: subscriptionService.currentTier)
                )
            }
            .accessibilityElement(children: .combine)

            // Lifetime plan commented out until pricing is finalized
            if let renewalDate = subscriptionService.renewalDate {
                HStack {
                    ChronirText("Renews", style: .bodyPrimary)
                    Spacer()
                    ChronirText(
                        renewalDate.formatted(date: .abbreviated, time: .omitted),
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
                .accessibilityElement(children: .combine)
            }

            if let productID = subscriptionService.activeProductID,
               let product = subscriptionService.product(for: productID) {
                HStack {
                    ChronirText("Price", style: .bodyPrimary)
                    Spacer()
                    ChronirText(
                        priceWithPeriod(product),
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
                .accessibilityElement(children: .combine)
            }
        } header: {
            Text("Your Plan")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private func priceWithPeriod(_ product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return product.displayPrice }
        switch period.unit {
        case .day: return "\(product.displayPrice)/day"
        case .week: return "\(product.displayPrice)/week"
        case .month: return "\(product.displayPrice)/month"
        case .year: return "\(product.displayPrice)/year"
        @unknown default: return product.displayPrice
        }
    }

    // MARK: - Plan Comparison

    // TODO: Add Premium column back when Premium tier is built (Phase 4, Sprint 11+)
    private var planComparisonSection: some View {
        Section {
            Grid(alignment: .leading, horizontalSpacing: SpacingTokens.md, verticalSpacing: SpacingTokens.sm) {
                GridRow {
                    Text("Feature")
                    Text("Free").gridColumnAlignment(.center)
                    Text("Plus").gridColumnAlignment(.center)
                }
                .chronirFont(.labelMedium)
                .foregroundStyle(ColorTokens.textSecondary)
                .accessibilityHidden(true)

                Divider()

                ForEach(PlusFeature.allCases) { feature in
                    GridRow {
                        ChronirText(feature.shortTitle, style: .bodyMedium)
                        comparisonValue(feature.freeValue, included: false)
                        comparisonValue(feature.plusValue, included: true)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(comparisonAccessibilityLabel(feature))
                }
            }
            .padding(.vertical, SpacingTokens.xs)
        } header: {
            Text("Plan Comparison")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    @ViewBuilder
    private func comparisonValue(_ value: String?, included: Bool) -> some View {
        Group {
            if let value {
                ChronirText(value, style: .labelMedium, color: ColorTokens.textPrimary)
            } else if included {
                Image(systemName: "checkmark")
                    .foregroundStyle(ColorTokens.textPrimary)
            } else {
                Image(systemName: "minus")
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
        .font(.body.weight(.semibold))
        .frame(minWidth: SpacingTokens.touchMinTarget)
    }

    private func comparisonAccessibilityLabel(_ feature: PlusFeature) -> String {
        let free = feature.freeValue ?? "not included"
        let plus = feature.plusValue ?? "included"
        return "\(feature.shortTitle). Free: \(free). Plus: \(plus)."
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section {
            if subscriptionService.currentTier.isFreeTier {
                Button { showPaywall = true } label: {
                    ChronirText("Upgrade to Plus", style: .bodyPrimary, color: ColorTokens.primary)
                }
            } else /* if !subscriptionService.isLifetime */ {
                Button {
                    Task { await showManageSubscriptions() }
                } label: {
                    ChronirText("Change Plan", style: .bodyPrimary, color: ColorTokens.primary)
                }
            }

            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                HStack {
                    ChronirText("Restore Purchases", style: .bodyPrimary, color: ColorTokens.primary)
                    Spacer()
                    if subscriptionService.isLoading {
                        ProgressView()
                    }
                }
            }
            .disabled(subscriptionService.isLoading)
        } header: {
            Text("Manage")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private func showManageSubscriptions() async {
        #if os(iOS)
        if let scene = windowScene {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
                return
            } catch {
                AnalyticsService.shared.recordError(error, context: "show_manage_subscriptions")
            }
        }
        #endif
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            openURL(url)
        }
    }

    private func badgeColor(for tier: SubscriptionTier) -> Color {
        switch tier {
        case .free: return ColorTokens.textSecondary
        case .plus: return ColorTokens.primary
        case .premium: return ColorTokens.badgeWarning
        case .family: return ColorTokens.badgeSuccess
        }
    }

    #if os(iOS)
    private var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }
    #endif
}

#Preview("Light") {
    NavigationStack {
        SubscriptionManagementView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        SubscriptionManagementView()
    }
    .preferredColorScheme(.dark)
}
