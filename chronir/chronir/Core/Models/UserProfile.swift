import Foundation

enum SubscriptionTier: String, Codable, CaseIterable {
    case free
    case plus
    case premium
    case family

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .plus: return "Plus"
        case .premium: return "Premium"
        case .family: return "Family"
        }
    }

    var alarmLimit: Int? {
        switch self {
        case .free: return 2
        case .plus, .premium, .family: return nil
        }
    }

    var isFreeTier: Bool {
        self == .free
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
