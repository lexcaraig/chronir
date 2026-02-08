import Foundation
#if canImport(UserNotifications)
@preconcurrency import UserNotifications
#endif

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func registerCategories()
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
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
    }

    func registerCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 1 Hour",
            options: []
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )

        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([alarmCategory])
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard let alarmIDString = notification.request.content.userInfo["alarmID"] as? String,
              let alarmID = UUID(uuidString: alarmIDString) else {
            completionHandler([.banner, .sound, .badge])
            return
        }

        Task { @MainActor in
            AlarmFiringCoordinator.shared.presentAlarm(id: alarmID)
        }

        // Suppress system banner — full-screen UI is showing
        completionHandler([])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let alarmIDString = response.notification.request.content.userInfo["alarmID"] as? String

        switch actionIdentifier {
        case "SNOOZE_ACTION":
            handleSnoozeAction(alarmIDString: alarmIDString)
        case "DISMISS_ACTION":
            handleDismissAction(alarmIDString: alarmIDString)
        case UNNotificationDefaultActionIdentifier:
            // User tapped notification — present full-screen alarm UI
            if let alarmIDString, let alarmID = UUID(uuidString: alarmIDString) {
                Task { @MainActor in
                    AlarmFiringCoordinator.shared.presentAlarm(id: alarmID)
                }
            }
        default:
            break
        }

        completionHandler()
    }

    // MARK: - Action Handlers

    private func handleSnoozeAction(alarmIDString: String?) {
        guard let alarmIDString, let alarmID = UUID(uuidString: alarmIDString) else { return }

        // Schedule snooze notification for 1 hour from now
        let content = UNMutableNotificationContent()
        content.title = "Snoozed Alarm"
        content.body = "Your alarm is firing again"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmID": alarmIDString]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(alarmIDString)_snooze",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)

        // Update snoozeCount via repository
        Task {
            guard let repo = AlarmRepository.shared else { return }
            if let alarm = try? await repo.fetch(by: alarmID) {
                alarm.snoozeCount += 1
                try? await repo.update(alarm)
            }
        }
    }

    private func handleDismissAction(alarmIDString: String?) {
        guard let alarmIDString, let alarmID = UUID(uuidString: alarmIDString) else { return }

        Task {
            guard let repo = AlarmRepository.shared else { return }
            guard let alarm = try? await repo.fetch(by: alarmID) else { return }

            let dateCalculator = DateCalculator()
            alarm.lastFiredDate = Date()
            alarm.snoozeCount = 0
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try? await repo.update(alarm)

            // Cancel old and schedule new
            let scheduler = AlarmScheduler.shared
            try? await scheduler.cancelAlarm(alarm)
            try? await scheduler.scheduleAlarm(alarm)
        }
    }
}
#else
final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    func requestAuthorization() async throws -> Bool { false }
    func registerCategories() {}
}
#endif
