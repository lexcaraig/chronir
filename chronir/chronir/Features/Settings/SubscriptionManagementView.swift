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

            // Lifetime plan commented out until pricing is finalized
            // if subscriptionService.isLifetime {
            //     HStack {
            //         ChronirText("Duration", style: .bodyPrimary)
            //         Spacer()
            //         ChronirText("Forever", style: .bodySecondary, color: ColorTokens.success)
            //     }
            // } else
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

    // TODO: Add Premium column back when Premium tier is built (Phase 4, Sprint 11+)
    private var planComparisonSection: some View {
        Section {
            comparisonRow("Alarms", free: "3", plus: "Unlimited")
            comparisonRow("Custom Snooze", free: "—", plus: "Yes")
            comparisonRow("Pre-Alarm Warnings", free: "—", plus: "Yes")
            comparisonRow("Photo Attachments", free: "—", plus: "Yes")
            comparisonRow("Completion History", free: "—", plus: "Yes")
        } header: {
            ChronirText("Plan Comparison", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private func comparisonRow(_ feature: String, free: String, plus: String) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText(feature, style: .bodyPrimary)
            HStack {
                tierValue("Free", value: free)
                Spacer()
                tierValue("Plus", value: plus)
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
            if !subscriptionService.currentTier.isFreeTier /* && !subscriptionService.isLifetime */ {
                Button {
                    Task {
                        guard let scene = windowScene else { return }
                        try? await AppStore.showManageSubscriptions(in: scene)
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
                    await subscriptionService.restorePurchases()
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

#Preview {
    NavigationStack {
        SubscriptionManagementView()
    }
}
