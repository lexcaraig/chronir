import Foundation
import SwiftData

@Model
final class Alarm: Identifiable {
    @Attribute(.unique) var id: UUID

    // MARK: - Core Identity
    var title: String
    var note: String?

    // MARK: - Schedule
    var cycleType: CycleType
    var timeOfDayHour: Int
    var timeOfDayMinute: Int
    var scheduleData: Data
    var nextFireDate: Date
    var lastFiredDate: Date?

    // MARK: - Timezone
    var timezone: String
    var timezoneMode: TimezoneMode

    // MARK: - State
    var isEnabled: Bool
    var snoozeCount: Int

    // MARK: - Behavior
    var persistenceLevel: PersistenceLevel
    var dismissMethod: DismissMethod
    var preAlarmMinutes: Int

    // MARK: - Appearance
    var colorTag: String?
    var iconName: String?

    // MARK: - Organization
    var category: String?

    // MARK: - Sync & Sharing
    var syncStatus: SyncStatus
    var ownerID: String?
    var sharedWith: [String]

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed: Schedule

    @Transient
    var schedule: Schedule {
        get {
            // swiftlint:disable:next force_try
            try! JSONDecoder().decode(Schedule.self, from: scheduleData)
        }
        set {
            // swiftlint:disable:next force_try
            scheduleData = try! JSONEncoder().encode(newValue)
        }
    }

    @Transient
    var scheduledTime: Date {
        let cal = Calendar.current
        return cal.date(from: DateComponents(hour: timeOfDayHour, minute: timeOfDayMinute)) ?? Date()
    }

    @Transient
    var isPersistent: Bool {
        persistenceLevel == .full
    }

    @Transient
    var alarmCategory: AlarmCategory? {
        get { category.flatMap { AlarmCategory(rawValue: $0) } }
        set { category = newValue?.rawValue }
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        title: String,
        cycleType: CycleType = .weekly,
        timeOfDayHour: Int = 8,
        timeOfDayMinute: Int = 0,
        schedule: Schedule = .weekly(daysOfWeek: [2], interval: 1),
        nextFireDate: Date = Date(),
        lastFiredDate: Date? = nil,
        timezone: String = TimeZone.current.identifier,
        timezoneMode: TimezoneMode = .floating,
        isEnabled: Bool = true,
        snoozeCount: Int = 0,
        persistenceLevel: PersistenceLevel = .notificationOnly,
        dismissMethod: DismissMethod = .swipe,
        preAlarmMinutes: Int = 0,
        colorTag: String? = nil,
        iconName: String? = nil,
        category: String? = nil,
        syncStatus: SyncStatus = .localOnly,
        ownerID: String? = nil,
        sharedWith: [String] = [],
        note: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.cycleType = cycleType
        self.timeOfDayHour = timeOfDayHour
        self.timeOfDayMinute = timeOfDayMinute
        // swiftlint:disable:next force_try
        self.scheduleData = try! JSONEncoder().encode(schedule)
        self.nextFireDate = nextFireDate
        self.lastFiredDate = lastFiredDate
        self.timezone = timezone
        self.timezoneMode = timezoneMode
        self.isEnabled = isEnabled
        self.snoozeCount = snoozeCount
        self.persistenceLevel = persistenceLevel
        self.dismissMethod = dismissMethod
        self.preAlarmMinutes = preAlarmMinutes
        self.colorTag = colorTag
        self.iconName = iconName
        self.category = category
        self.syncStatus = syncStatus
        self.ownerID = ownerID
        self.sharedWith = sharedWith
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
