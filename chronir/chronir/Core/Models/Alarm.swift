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
    var timesOfDayData: Data?
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
    var preAlarmOffsetsData: Data?

    // MARK: - Sound
    var soundName: String?

    // MARK: - Attachments
    var photoFileName: String?

    // MARK: - Appearance
    var colorTag: String?
    var iconName: String?

    // MARK: - Organization
    var category: String?

    // MARK: - Sync & Sharing
    var syncStatus: SyncStatus
    var ownerID: String?
    var sharedWith: [String]

    // MARK: - Completion History
    @Relationship(deleteRule: .cascade, inverse: \CompletionLog.alarm)
    var completionLogs: [CompletionLog] = []
    var lastCompletedAt: Date?

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed: Schedule

    private static let defaultSchedule: Schedule = .weekly(daysOfWeek: [2], interval: 1)

    @Transient
    var schedule: Schedule {
        get {
            (try? JSONDecoder().decode(Schedule.self, from: scheduleData))
                ?? Self.defaultSchedule
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                scheduleData = encoded
            }
        }
    }

    @Transient
    var timesOfDay: [TimeOfDay] {
        get {
            guard let data = timesOfDayData,
                  let decoded = try? JSONDecoder().decode([TimeOfDay].self, from: data),
                  !decoded.isEmpty else {
                return [TimeOfDay(hour: timeOfDayHour, minute: timeOfDayMinute)]
            }
            return decoded.sorted()
        }
        set {
            let sorted = newValue.sorted()
            timesOfDayData = try? JSONEncoder().encode(sorted)
            if let first = sorted.first {
                timeOfDayHour = first.hour
                timeOfDayMinute = first.minute
            }
        }
    }

    @Transient
    var hasMultipleTimes: Bool {
        timesOfDay.count > 1
    }

    @Transient
    var scheduledTime: Date {
        let now = Date()
        let cal = Calendar.current
        let times = timesOfDay
        // Find the next upcoming time today
        for time in times {
            if let candidate = cal.date(from: DateComponents(hour: time.hour, minute: time.minute)),
               candidate > now {
                return candidate
            }
        }
        // All times passed today — return the first time (for display)
        let first = times.first ?? TimeOfDay(hour: timeOfDayHour, minute: timeOfDayMinute)
        return cal.date(from: DateComponents(hour: first.hour, minute: first.minute)) ?? Date()
    }

    @Transient
    var isPersistent: Bool {
        persistenceLevel == .full
    }

    @Transient
    var preAlarmOffsets: [PreAlarmOffset] {
        get {
            if let data = preAlarmOffsetsData,
               let decoded = try? JSONDecoder().decode([PreAlarmOffset].self, from: data) {
                return decoded.sorted()
            }
            // Migrate legacy field
            if preAlarmMinutes == 1440 { return [.oneDay] }
            return []
        }
        set {
            preAlarmOffsetsData = try? JSONEncoder().encode(newValue.sorted())
            // Keep legacy field in sync for backward compat
            preAlarmMinutes = newValue.contains(.oneDay) ? 1440 : (newValue.isEmpty ? 0 : 1)
        }
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
        timesOfDay: [TimeOfDay]? = nil,
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
        if let times = timesOfDay, !times.isEmpty {
            let sorted = times.sorted()
            self.timeOfDayHour = sorted[0].hour
            self.timeOfDayMinute = sorted[0].minute
            self.timesOfDayData = try? JSONEncoder().encode(sorted)
        } else {
            self.timeOfDayHour = timeOfDayHour
            self.timeOfDayMinute = timeOfDayMinute
            self.timesOfDayData = nil
        }
        self.scheduleData = (try? JSONEncoder().encode(schedule))
            ?? Data()
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
