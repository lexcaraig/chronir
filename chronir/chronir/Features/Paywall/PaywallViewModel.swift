import Foundation
import Observation
import StoreKit

@Observable
final class PaywallViewModel {
    enum ProductLoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    struct Alert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private let subscriptionService = SubscriptionService.shared

    /// Whether the StoreKit products behind the plan picker are available. The paywall never shows a
    /// price that didn't come from StoreKit.
    private(set) var productLoadState: ProductLoadState = .loading
    var alert: Alert?

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

    private var hasAllPlans: Bool {
        plusMonthly != nil && plusAnnual != nil
    }

    func canCreateAlarm(currentCount: Int) -> Bool {
        guard let limit = alarmLimit else { return true }
        return currentCount < limit
    }

    func loadSubscriptionStatus() async {
        AnalyticsService.shared.logEvent(AnalyticsEvent.upgradePromptShown, parameters: nil)
        await loadProducts()
        await subscriptionService.updateSubscriptionStatus()
    }

    /// Loads products; on failure shows the inline "Couldn't reach the App Store" state instead of an alert.
    func loadProducts() async {
        if !hasAllPlans { productLoadState = .loading }
        await subscriptionService.loadProducts()
        if hasAllPlans {
            productLoadState = .loaded
        } else {
            productLoadState = .failed
            // The inline failure state replaces the service's generic error alert.
            errorMessage = nil
        }
    }

    func purchase(_ product: Product?) async {
        guard let product else {
            alert = Alert(
                title: "Plan unavailable",
                message: "Couldn't load this plan from the App Store. Check your connection and try again."
            )
            return
        }
        do {
            try await subscriptionService.purchase(product)
            AnalyticsService.shared.logEvent(AnalyticsEvent.upgradeCompleted, parameters: [
                "product_id": product.id
            ])
        } catch {
            alert = Alert(title: "Purchase didn't go through", message: error.localizedDescription)
        }
    }

    func restorePurchases() async {
        errorMessage = nil
        await subscriptionService.restorePurchases()
        if errorMessage != nil {
            errorMessage = nil
            alert = Alert(
                title: "Couldn't restore purchases",
                message: "Couldn't reach the App Store. Check your connection and try again."
            )
        } else if isFreeTier {
            alert = Alert(
                title: "No subscription found",
                message: "There's no active Chronir Plus subscription for this Apple ID."
            )
        } else {
            alert = Alert(title: "Purchases restored", message: "You're on \(currentTier.displayName).")
        }
    }

    // Convenience accessors
    var plusMonthly: Product? { subscriptionService.plusMonthly }
    var plusAnnual: Product? { subscriptionService.plusAnnual }
    // var plusLifetime: Product? { subscriptionService.plusLifetime }
}
