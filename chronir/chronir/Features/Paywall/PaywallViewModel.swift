import Foundation
import Observation

@Observable
final class PaywallViewModel {
    // TODO: Implement in Sprint 5

    var currentTier: SubscriptionTier = .free
    var isLoading: Bool = false
    var errorMessage: String?

    func loadSubscriptionStatus() async {
        // TODO: Implement in Sprint 5 - StoreKit 2 integration
    }

    func purchase(tier: SubscriptionTier) async {
        // TODO: Implement in Sprint 5
    }

    func restorePurchases() async {
        // TODO: Implement in Sprint 5
    }
}
