import Foundation
import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleLocalNotification(for alarm: Alarm) async throws
    func removeNotification(for alarmID: UUID) async
    func removeAllNotifications() async
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() async throws -> Bool {
        // TODO: Implement in Sprint 2
        return false
    }

    func scheduleLocalNotification(for alarm: Alarm) async throws {
        // TODO: Implement in Sprint 2
    }

    func removeNotification(for alarmID: UUID) async {
        // TODO: Implement in Sprint 2
    }

    func removeAllNotifications() async {
        // TODO: Implement in Sprint 2
    }
}
