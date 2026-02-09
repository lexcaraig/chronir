import Foundation
import UserNotifications
import AlarmKit

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case provisional
}

protocol PermissionManaging: Sendable {
    func notificationPermissionStatus() async -> PermissionStatus
    func requestNotificationPermission() async throws -> Bool
    func requestAlarmPermission() async -> Bool
}

final class PermissionManager: PermissionManaging {
    static let shared = PermissionManager()

    private init() {}

    func notificationPermissionStatus() async -> PermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .provisional:
            return .provisional
        @unknown default:
            return .notDetermined
        }
    }

    func requestNotificationPermission() async throws -> Bool {
        return try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func requestAlarmPermission() async -> Bool {
        if AlarmManager.shared.authorizationState == .authorized {
            return true
        }

        do {
            let state = try await AlarmManager.shared.requestAuthorization()
            return state == .authorized
        } catch {
            return false
        }
    }
}
