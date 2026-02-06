import Foundation

// TODO: Replace with AlarmKit when Xcode 18/iOS 26 is available

protocol AlarmScheduling: Sendable {
    func scheduleAlarm(_ alarm: Alarm) async throws
    func cancelAlarm(_ alarm: Alarm) async throws
    func rescheduleAllAlarms() async throws
}

final class AlarmScheduler: AlarmScheduling {
    static let shared = AlarmScheduler()

    private init() {}

    func scheduleAlarm(_ alarm: Alarm) async throws {
        // TODO: Implement in Sprint 2
        // Will use UNUserNotificationCenter for now,
        // migrate to AlarmKit when iOS 26 SDK is available
    }

    func cancelAlarm(_ alarm: Alarm) async throws {
        // TODO: Implement in Sprint 2
    }

    func rescheduleAllAlarms() async throws {
        // TODO: Implement in Sprint 2
    }
}
