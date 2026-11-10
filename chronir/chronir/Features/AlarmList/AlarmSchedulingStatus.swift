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

    /// Persisted (UserDefaults, not SwiftData) so the "won't ring" warning survives a relaunch.
    /// An entry is cleared only by a later successful schedule, disabling, or deleting the alarm.
    private(set) var failedAlarmIDs: Set<UUID>

    private static let defaultsKey = "failedAlarmIDs"

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? []
        failedAlarmIDs = Set(stored.compactMap(UUID.init(uuidString:)))
    }

    /// Writes only on a real change: every write to an observed set re-renders the alarm list.
    private func markFailed(_ id: UUID, _ failed: Bool) {
        guard failedAlarmIDs.contains(id) != failed else { return }
        if failed { failedAlarmIDs.insert(id) } else { failedAlarmIDs.remove(id) }
        UserDefaults.standard.set(failedAlarmIDs.map(\.uuidString), forKey: Self.defaultsKey)
    }

    /// Registers the alarm with `AlarmScheduler` and records the outcome.
    /// Returns `true` only when AlarmKit accepted the registration.
    @discardableResult
    func schedule(_ alarm: Alarm) async -> Bool {
        do {
            try await AlarmScheduler.shared.scheduleAlarm(alarm)
            markFailed(alarm.id, false)
            return true
        } catch {
            markFailed(alarm.id, true)
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
        markFailed(id, false)
    }

    /// Drops warnings for alarms that another path (launch reschedule, Siri, widget) has since
    /// registered with AlarmKit, so a persisted warning never claims a scheduled alarm won't ring.
    func reconcile() {
        guard !failedAlarmIDs.isEmpty else { return }
        let registered: [AlarmKit.Alarm]
        do {
            registered = try AlarmManager.shared.alarms
        } catch {
            return // can't tell; keep the warnings rather than hide a real failure
        }
        let scheduled = Set(registered.map { AlarmScheduler.baseAlarmID(for: $0.id) })
        for id in failedAlarmIDs.intersection(scheduled) {
            markFailed(id, false)
        }
    }
}
