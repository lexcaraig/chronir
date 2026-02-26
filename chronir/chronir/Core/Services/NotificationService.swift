import Foundation
@preconcurrency import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func schedulePreAlarmNotification(for alarm: Alarm) async
    func schedulePreAlarmNotifications(for alarm: Alarm) async
    func cancelPreAlarmNotification(for alarm: Alarm)
    func cancelAllPreAlarmNotifications(for alarm: Alarm)
    func scheduleBackupNotification(for alarm: Alarm) async
    func cancelBackupNotification(for alarm: Alarm)
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

    func schedulePreAlarmNotifications(for alarm: Alarm) async {
        let offsets = alarm.preAlarmOffsets
        guard !offsets.isEmpty, alarm.isEnabled else { return }

        let settings = await notificationCenter.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        }
        guard settings.authorizationStatus != .denied else { return }

        // Cancel existing before rescheduling
        cancelAllPreAlarmNotifications(for: alarm)

        for offset in offsets {
            let preAlarmDate = alarm.nextFireDate.addingTimeInterval(-offset.timeInterval)
            guard preAlarmDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(alarm.title) \(offset.notificationBody)"
            content.body = "Scheduled for \(alarm.scheduledTime.formatted(date: .omitted, time: .shortened))"
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: preAlarmDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "pre-alarm-\(alarm.id.uuidString)-\(offset.rawValue)",
                content: content,
                trigger: trigger
            )

            try? await notificationCenter.add(request)
        }
    }

    func cancelPreAlarmNotification(for alarm: Alarm) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["pre-alarm-\(alarm.id.uuidString)"]
        )
    }

    func cancelAllPreAlarmNotifications(for alarm: Alarm) {
        let ids = PreAlarmOffset.allCases.map { "pre-alarm-\(alarm.id.uuidString)-\($0.rawValue)" }
            + ["pre-alarm-\(alarm.id.uuidString)"] // Legacy single notification
            + ["backup-alarm-\(alarm.id.uuidString)"]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Backup Notifications

    func scheduleBackupNotification(for alarm: Alarm) async {
        guard alarm.isEnabled, alarm.nextFireDate > Date() else { return }

        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus != .denied else { return }

        cancelBackupNotification(for: alarm)

        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.body = "Alarm firing — open Chronir"
        content.sound = .defaultCritical

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: alarm.nextFireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "backup-alarm-\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    func cancelBackupNotification(for alarm: Alarm) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["backup-alarm-\(alarm.id.uuidString)"]
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
        let categoryID = response.notification.request.content.categoryIdentifier
        let actionID = response.actionIdentifier

        if categoryID == "PENDING_CONFIRMATION",
           let alarmID = response.notification.request.content.userInfo["alarmID"] as? String {
            PendingConfirmationService.handleNotificationAction(
                actionIdentifier: actionID,
                alarmIDString: alarmID
            )
        }

        completionHandler()
    }

    // MARK: - Pending Confirmation Category

    func registerPendingConfirmationCategory() {
        Task { @MainActor in
            await PendingConfirmationService.shared.registerNotificationCategory()
        }
    }
}
#else
final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    func requestAuthorization() async throws -> Bool { false }
    func schedulePreAlarmNotification(for alarm: Alarm) async {}
    func schedulePreAlarmNotifications(for alarm: Alarm) async {}
    func cancelPreAlarmNotification(for alarm: Alarm) {}
    func cancelAllPreAlarmNotifications(for alarm: Alarm) {}
    func scheduleBackupNotification(for alarm: Alarm) async {}
    func cancelBackupNotification(for alarm: Alarm) {}
}
#endif
