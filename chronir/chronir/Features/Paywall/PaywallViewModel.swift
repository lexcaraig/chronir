import Foundation
import Observation
import StoreKit

@Observable
final class PaywallViewModel {
    private let subscriptionService = SubscriptionService.shared

    var currentTier: SubscriptionTier {
        subscriptionService.currentTier
    }

    var isLoading: Bool {
        subscriptionService.isLoading
    }

    var errorMessage: String? {
        get { subscriptionService.errorMessage }
        set { subscriptionService.errorMessage = newValue }
    }

    var isFreeTier: Bool {
        currentTier.isFreeTier
    }

    var alarmLimit: Int? {
        currentTier.alarmLimit
    }

    var products: [Product] {
        subscriptionService.products
    }

    func canCreateAlarm(currentCount: Int) -> Bool {
        guard let limit = alarmLimit else { return true }
        return currentCount < limit
    }

    func loadSubscriptionStatus() async {
        await subscriptionService.loadProducts()
        await subscriptionService.updateSubscriptionStatus()
        AnalyticsService.shared.logEvent(AnalyticsEvent.upgradePromptShown, parameters: nil)
    }

    func purchase(_ product: Product) async {
        do {
            try await subscriptionService.purchase(product)
            AnalyticsService.shared.logEvent(AnalyticsEvent.upgradeCompleted, parameters: [
                "product_id": product.id
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        await subscriptionService.restorePurchases()
    }

    // Convenience accessors
    var plusMonthly: Product? { subscriptionService.plusMonthly }
    var plusAnnual: Product? { subscriptionService.plusAnnual }
    // var plusLifetime: Product? { subscriptionService.plusLifetime }
}
