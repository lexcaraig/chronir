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

    /// Alarm IDs that transitioned out of `.alerting` while backgrounded and were NOT
    /// fired in-app. If the user stopped the alarm on the lock screen, the ID appears here.
    /// On foreground, these are auto-completed. IDs NOT in this set are treated as missed
    /// and presented via the firing screen.
    var stoppedOnLockScreen: Set<UUID> = []

    /// Alarm IDs currently being presented as past-due (missed) alarms.
    /// Protects against race conditions where a buffered `alarmUpdates` default event
    /// clears `stoppedForCustomSound` before the firing view fully initializes,
    /// which would cause `scenePhase`/Case 1 fallbacks to incorrectly dismiss.
    var presentingPastDue: Set<UUID> = []

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
        if let id = firingAlarmID {
            presentingPastDue.remove(id)
            stoppedForCustomSound.remove(id)
        }
        firingAlarmID = nil
    }
}
