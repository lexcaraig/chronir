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

enum PreAlarmOffset: String, Codable, CaseIterable, Identifiable, Comparable {
    case oneHour
    case oneDay
    case threeDays
    case sevenDays

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneHour: return "1 hour"
        case .oneDay: return "1 day"
        case .threeDays: return "3 days"
        case .sevenDays: return "7 days"
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .oneHour: return 3600
        case .oneDay: return 86400
        case .threeDays: return 259200
        case .sevenDays: return 604800
        }
    }

    var notificationBody: String {
        switch self {
        case .oneHour: return "in 1 hour"
        case .oneDay: return "tomorrow"
        case .threeDays: return "in 3 days"
        case .sevenDays: return "in 1 week"
        }
    }

    /// Free tier only gets 1-day pre-alarm
    var requiresPlus: Bool {
        self != .oneDay
    }

    private var sortOrder: Int {
        switch self {
        case .oneHour: return 0
        case .oneDay: return 1
        case .threeDays: return 2
        case .sevenDays: return 3
        }
    }

    static func < (lhs: PreAlarmOffset, rhs: PreAlarmOffset) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
