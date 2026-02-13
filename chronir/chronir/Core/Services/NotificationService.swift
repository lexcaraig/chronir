import Foundation
@preconcurrency import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func schedulePreAlarmNotification(for alarm: Alarm) async
    func cancelPreAlarmNotification(for alarm: Alarm)
}

#if os(iOS)
final class NotificationService: NSObject, NotificationServiceProtocol, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() async throws -> Bool {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Pre-Alarm Notifications

    func schedulePreAlarmNotification(for alarm: Alarm) async {
        guard alarm.preAlarmMinutes > 0, alarm.isEnabled else { return }

        let preAlarmDate = alarm.nextFireDate.addingTimeInterval(-Double(alarm.preAlarmMinutes) * 60)
        guard preAlarmDate > Date() else { return }

        // Ensure notification authorization before scheduling
        let settings = await notificationCenter.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        }
        guard settings.authorizationStatus != .denied else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Alarm"
        content.body = "\"\(alarm.title)\" fires in \(alarm.preAlarmMinutes / 60) hours"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: preAlarmDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "pre-alarm-\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    func cancelPreAlarmNotification(for alarm: Alarm) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["pre-alarm-\(alarm.id.uuidString)"]
        )
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
#else
final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    func requestAuthorization() async throws -> Bool { false }
    func schedulePreAlarmNotification(for alarm: Alarm) async {}
    func cancelPreAlarmNotification(for alarm: Alarm) {}
}
#endif
