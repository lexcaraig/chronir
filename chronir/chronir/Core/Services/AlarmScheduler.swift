import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

// TODO: Replace with AlarmKit when Xcode 18/iOS 26 is available

protocol AlarmScheduling: Sendable {
    func scheduleAlarm(_ alarm: Alarm) async throws
    func cancelAlarm(_ alarm: Alarm) async throws
    func rescheduleAllAlarms() async throws
}

final class AlarmScheduler: AlarmScheduling {
    static let shared = AlarmScheduler()

    private let repository: AlarmRepositoryProtocol
    private let dateCalculator: DateCalculator

    init(
        repository: AlarmRepositoryProtocol = AlarmRepository.shared,
        dateCalculator: DateCalculator = DateCalculator()
    ) {
        self.repository = repository
        self.dateCalculator = dateCalculator
    }

    func scheduleAlarm(_ alarm: Alarm) async throws {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.body = alarm.note ?? "Alarm"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmID": alarm.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: alarm.nextFireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
        #endif
    }

    func cancelAlarm(_ alarm: Alarm) async throws {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        center.removeDeliveredNotifications(withIdentifiers: [alarm.id.uuidString])
        #endif
    }

    func rescheduleAllAlarms() async throws {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let alarms = try await repository.fetchEnabled()
        for alarm in alarms {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try await scheduleAlarm(alarm)
        }
        #endif
    }
}
