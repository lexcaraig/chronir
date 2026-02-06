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
            title: "Snooze 5 min",
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
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let alarmID = response.notification.request.content.userInfo["alarmID"] as? String

        switch actionIdentifier {
        case "SNOOZE_ACTION":
            // TODO: Re-schedule for 5 minutes from now
            break
        case "DISMISS_ACTION", UNNotificationDefaultActionIdentifier:
            // TODO: Mark alarm as dismissed, calculate next fire date
            break
        default:
            break
        }

        completionHandler()
    }
}
#else
final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    func requestAuthorization() async throws -> Bool { false }
    func registerCategories() {}
}
#endif
