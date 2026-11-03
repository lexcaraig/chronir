import Foundation
import Observation
@preconcurrency import AlarmKit

/// Records alarms whose AlarmKit registration failed after a user action (create, edit, toggle,
/// skip), so the alarm list can say "not scheduled" instead of letting the user believe the alarm
/// will ring. AlarmKit never launches the app, so a failed registration does not fix itself (AE-02).
@MainActor
@Observable
final class AlarmSchedulingStatus {
    static let shared = AlarmSchedulingStatus()

    private(set) var failedAlarmIDs: Set<UUID> = []

    private init() {}

    /// Registers the alarm with `AlarmScheduler` and records the outcome.
    /// Returns `true` only when AlarmKit accepted the registration.
    @discardableResult
    func schedule(_ alarm: Alarm) async -> Bool {
        do {
            try await AlarmScheduler.shared.scheduleAlarm(alarm)
            // `scheduleAlarm` returns without registering anything when alarm permission is denied.
            guard AlarmManager.shared.authorizationState == .authorized else {
                failedAlarmIDs.insert(alarm.id)
                return false
            }
            failedAlarmIDs.remove(alarm.id)
            return true
        } catch {
            failedAlarmIDs.insert(alarm.id)
            return false
        }
    }

    /// Cancels then re-registers an edited alarm. Disabled alarms are only cancelled.
    @discardableResult
    func reschedule(_ alarm: Alarm) async -> Bool {
        do {
            try await AlarmScheduler.shared.cancelAlarm(alarm)
        } catch {
            AnalyticsService.shared.recordError(error, context: "cancel_alarm_reschedule")
        }
        guard alarm.isEnabled else {
            clear(alarm.id)
            return true
        }
        return await schedule(alarm)
    }

    func clear(_ id: UUID) {
        failedAlarmIDs.remove(id)
    }
}
