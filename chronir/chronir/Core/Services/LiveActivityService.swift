import Foundation

#if canImport(ActivityKit)
import ActivityKit

@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()

    private var currentActivityID: String?
    private var currentAlarmID: String?

    private let repository: AlarmRepositoryProtocol

    private init(repository: AlarmRepositoryProtocol = AlarmRepository.shared) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Idempotent refresh: starts, updates, or ends the Live Activity based on current alarm state.
    /// Call from every alarm lifecycle event.
    func refreshLiveActivity() async {
        guard UserSettings.shared.liveActivityEnabled,
              ActivityAuthorizationInfo().areActivitiesEnabled else {
            await endCurrentActivity()
            return
        }

        let now = Date()
        let cutoff = now.addingTimeInterval(60 * 60) // 1 hour

        guard let nextAlarm = await findNextImminentAlarm(before: cutoff, now: now) else {
            await endCurrentActivity()
            return
        }

        let alarmIDString = nextAlarm.id.uuidString
        let state = AlarmCountdownAttributes.ContentState(
            alarmTitle: nextAlarm.title,
            fireDate: nextAlarm.nextFireDate
        )

        // Same alarm — update content state
        if currentAlarmID == alarmIDString, let activityID = currentActivityID {
            if let activity = Activity<AlarmCountdownAttributes>.activities.first(where: { $0.id == activityID }) {
                await activity.update(ActivityContent(state: state, staleDate: nextAlarm.nextFireDate))
                return
            }
            // Activity was dismissed externally — fall through to start a new one
        }

        // Different alarm or no current activity — end old, start new
        await endCurrentActivity()

        let attributes = AlarmCountdownAttributes(
            alarmID: alarmIDString,
            cycleType: nextAlarm.cycleType.displayName
        )
        let content = ActivityContent(state: state, staleDate: nextAlarm.nextFireDate)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivityID = activity.id
            currentAlarmID = alarmIDString
        } catch {
            AnalyticsService.shared.recordError(error, context: "live_activity_start")
        }
    }

    /// End the current Live Activity immediately.
    func endCurrentActivity() async {
        guard let activityID = currentActivityID else { return }

        if let activity = Activity<AlarmCountdownAttributes>.activities.first(where: { $0.id == activityID }) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        currentActivityID = nil
        currentAlarmID = nil
    }

    /// Clean up orphaned activities on cold launch (e.g. app was killed).
    func cleanupOrphanedActivities() async {
        for activity in Activity<AlarmCountdownAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivityID = nil
        currentAlarmID = nil
    }

    // MARK: - Private

    private func findNextImminentAlarm(before cutoff: Date, now: Date) async -> Alarm? {
        guard let alarms = try? await repository.fetchAll() else { return nil }

        return alarms
            .filter { $0.isEnabled && $0.nextFireDate > now && $0.nextFireDate <= cutoff }
            .min(by: { $0.nextFireDate < $1.nextFireDate })
    }
}

#endif
