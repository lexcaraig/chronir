import Foundation
import Observation

@Observable
@MainActor
final class AlarmFiringCoordinator {
    static let shared = AlarmFiringCoordinator()

    var firingAlarmID: UUID?

    /// Alarm IDs seen in `.countdown` state via `alarmUpdates` (snoozed from lock screen).
    var snoozedInBackground: Set<UUID> = []

    /// Alarm IDs already processed, with the timestamp they were handled.
    /// Entries expire after `handledExpiry` seconds to allow legitimate re-fires
    /// (e.g., after snooze countdown) while blocking stale buffered events.
    private var handledAlarmEntries: [UUID: Date] = [:]
    private let handledExpiry: TimeInterval = 30

    /// Alarm IDs where we intentionally stopped AlarmKit to play a custom sound.
    /// The `alarmUpdates` default handler should NOT dismiss the firing view for these.
    var stoppedForCustomSound: Set<UUID> = []

    /// Set to `true` when the app resigns active (via `willResignActiveNotification`).
    /// Prevents stale `.alerting` events from presenting the firing screen when
    /// `alarmUpdates` resumes. Reset to `false` by the foreground handler after
    /// it processes all pending alarms.
    var appIsInBackground: Bool = false

    var isFiring: Bool {
        firingAlarmID != nil
    }

    private init() {}

    // MARK: - Handled Alarm Tracking

    func markHandled(_ id: UUID) {
        handledAlarmEntries[id] = Date()
    }

    func isHandled(_ id: UUID) -> Bool {
        guard let handledAt = handledAlarmEntries[id] else { return false }
        return Date().timeIntervalSince(handledAt) < handledExpiry
    }

    func clearHandled(_ id: UUID) {
        handledAlarmEntries.removeValue(forKey: id)
    }

    // MARK: - Presentation

    func presentAlarm(id: UUID) {
        snoozedInBackground.remove(id)
        clearHandled(id)
        firingAlarmID = id
    }

    func dismissFiring() {
        firingAlarmID = nil
    }
}
