import Foundation
import Observation

@Observable
final class PaywallViewModel {
    var currentTier: SubscriptionTier = .free
    var isLoading: Bool = false
    var errorMessage: String?

    var isFreeTier: Bool {
        currentTier.isFreeTier
    }

    var alarmLimit: Int? {
        currentTier.alarmLimit
    }

    func canCreateAlarm(currentCount: Int) -> Bool {
        guard let limit = alarmLimit else { return true }
        return currentCount < limit
    }

    func loadSubscriptionStatus() async {
        // TODO: StoreKit 2 integration (Sprint 8)
    }

    func purchase(tier: SubscriptionTier) async {
        // TODO: StoreKit 2 integration (Sprint 8)
    }

    func restorePurchases() async {
        // TODO: StoreKit 2 integration (Sprint 8)
    }
}
