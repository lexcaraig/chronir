import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    private let subscriptionService = SubscriptionService.shared
    @State private var restoreMessage: String?
    @Environment(\.dismiss) private var dismiss

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
            }

            if let productID = subscriptionService.activeProductID,
               let product = subscriptionService.product(for: productID) {
                HStack {
                    ChronirText("Price", style: .bodyPrimary)
                    Spacer()
                    ChronirText(
                        product.displayPrice,
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
            }
        } header: {
            ChronirText("Your Plan", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Plan Comparison

    private var planComparisonSection: some View {
        Section {
            comparisonRow("Alarms", free: "2", plus: "Unlimited", premium: "Unlimited")
            comparisonRow("Cloud Backup", free: "—", plus: "Yes", premium: "Yes")
            comparisonRow("Widgets", free: "—", plus: "Yes", premium: "Yes")
            comparisonRow("Photo Attachments", free: "—", plus: "Yes", premium: "Yes")
            comparisonRow("Shared Alarms", free: "—", plus: "—", premium: "Yes")
            comparisonRow("Groups", free: "—", plus: "—", premium: "Yes")
            comparisonRow("Live Activities", free: "—", plus: "—", premium: "Yes")
        } header: {
            ChronirText("Plan Comparison", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private func comparisonRow(_ feature: String, free: String, plus: String, premium: String) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText(feature, style: .bodyPrimary)
            HStack {
                tierValue("Free", value: free)
                Spacer()
                tierValue("Plus", value: plus)
                Spacer()
                tierValue("Premium", value: premium)
            }
        }
        .padding(.vertical, SpacingTokens.xxs)
    }

    private func tierValue(_ tier: String, value: String) -> some View {
        VStack(spacing: 2) {
            ChronirText(tier, style: .caption, color: ColorTokens.textSecondary)
            let valueColor = value == "—" ? ColorTokens.textSecondary : ColorTokens.success
            ChronirText(value, style: .labelSmall, color: valueColor)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section {
            if !subscriptionService.currentTier.isFreeTier {
                Button {
                    Task {
                        try? await AppStore.showManageSubscriptions(in: windowScene)
                    }
                } label: {
                    HStack {
                        ChronirText("Change Plan", style: .bodyPrimary, color: ColorTokens.primary)
                        Spacer()
                        ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
                    }
                }
            }

            Button {
                Task {
                    await SubscriptionService.shared.restorePurchases()
                    if subscriptionService.currentTier.isFreeTier {
                        restoreMessage = "No active subscriptions found."
                    } else {
                        restoreMessage = "Restored to \(subscriptionService.currentTier.displayName)."
                    }
                }
            } label: {
                if subscriptionService.isLoading {
                    ProgressView()
                } else {
                    ChronirText("Restore Purchases", style: .bodyPrimary, color: ColorTokens.primary)
                }
            }
            .disabled(subscriptionService.isLoading)
        } header: {
            ChronirText("Manage", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
        .alert("Restore Purchases", isPresented: .constant(restoreMessage != nil)) {
            Button("OK") { restoreMessage = nil }
        } message: {
            Text(restoreMessage ?? "")
        }
    }

    private func badgeColor(for tier: SubscriptionTier) -> Color {
        switch tier {
        case .free: return ColorTokens.textSecondary
        case .plus: return ColorTokens.primary
        case .premium: return ColorTokens.warning
        case .family: return ColorTokens.success
        }
    }

    #if os(iOS)
    private var windowScene: UIWindowScene {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first!
    }
    #endif
}

#Preview {
    NavigationStack {
        SubscriptionManagementView()
    }
}
