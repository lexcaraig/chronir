import Foundation

enum CycleType: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case biweekly
    case monthly
    case quarterly
    case yearly
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Biweekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        }
    }
}

struct Alarm: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var cycleType: CycleType
    var scheduledTime: Date
    var nextFireDate: Date
    var isEnabled: Bool
    var isPersistent: Bool
    var note: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        cycleType: CycleType,
        scheduledTime: Date,
        nextFireDate: Date,
        isEnabled: Bool = true,
        isPersistent: Bool = false,
        note: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.cycleType = cycleType
        self.scheduledTime = scheduledTime
        self.nextFireDate = nextFireDate
        self.isEnabled = isEnabled
        self.isPersistent = isPersistent
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
