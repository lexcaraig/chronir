import Foundation
@preconcurrency import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
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
}
#endif
