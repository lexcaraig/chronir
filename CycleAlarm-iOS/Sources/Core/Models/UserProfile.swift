import Foundation

enum SubscriptionTier: String, Codable, CaseIterable {
    case free
    case premium
    case family

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .family: return "Family"
        }
    }
}

struct UserProfile: Identifiable, Codable, Hashable {
    let id: String
    var displayName: String
    var email: String
    var tier: SubscriptionTier

    init(
        id: String,
        displayName: String,
        email: String,
        tier: SubscriptionTier = .free
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.tier = tier
    }
}
