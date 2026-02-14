import Foundation

enum CycleType: String, Codable, CaseIterable, Identifiable {
    case weekly
    case monthlyDate
    case monthlyRelative
    case annual
    case customDays
    case oneTime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthlyDate: return "Monthly"
        case .monthlyRelative: return "Monthly"
        case .annual: return "Annual"
        case .customDays: return "Custom"
        case .oneTime: return "One-Time"
        }
    }
}

enum TimezoneMode: String, Codable {
    case fixed
    case floating
}

enum PersistenceLevel: String, Codable {
    case full
    case notificationOnly
    case silent
}

enum DismissMethod: String, Codable {
    case swipe
    case hold3s
    case solveMath
}

enum SyncStatus: String, Codable {
    case localOnly
    case synced
    case pendingSync
    case conflict
}
