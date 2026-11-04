import AppIntents
import Foundation
import SwiftData
@preconcurrency import AlarmKit

// AlarmKit runs these in the app process when the user taps Stop or Snooze on the lock screen,
// Dynamic Island, or alarm banner. They tell the app which button was pressed: a snooze countdown
// is gone within a second (AlarmKit drops it; see scheduleSnoozeRefire), so the alarm list looks
// the same afterwards either way; inferring the button from state completed snoozed alarms.

struct StopAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop Alarm"
    static let isDiscoverable = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @Parameter(title: "Registration ID")
    var registrationID: String

    init() {}

    init(registrationID: UUID) {
        self.registrationID = registrationID.uuidString
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: registrationID) else { return .result() }
        try? AlarmManager.shared.stop(id: id)
        LockScreenAlarmActions.stop(registrationID: id)
        return .result()
    }
}

struct SnoozeAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Snooze Alarm"
    static let isDiscoverable = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @Parameter(title: "Registration ID")
    var registrationID: String

    init() {}

    init(registrationID: UUID) {
        self.registrationID = registrationID.uuidString
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: registrationID) else { return .result() }
        await LockScreenAlarmActions.snooze(registrationID: id)
        return .result()
    }
}

/// Lock-screen (system UI) alarm actions, shared by the button intents and the `alarmUpdates` handler.
@MainActor
enum LockScreenAlarmActions {
    private static func model(for registrationID: UUID) -> (Alarm, ModelContext)? {
        guard let context = AlarmRepository.shared?.modelContainer.mainContext else { return nil }
        let baseID = AlarmScheduler.baseAlarmID(for: registrationID)
        let descriptor = FetchDescriptor<Alarm>(predicate: #Predicate { $0.id == baseID && $0.isEnabled == true })
        guard let model = try? context.fetch(descriptor).first else { return nil }
        return (model, context)
    }

    /// Stopped from the system alarm UI: complete the occurrence that was ringing.
    static func stop(registrationID: UUID) {
        let coordinator = AlarmFiringCoordinator.shared
        guard let (model, context) = model(for: registrationID),
              model.nextFireDate <= Date(), // already handled (or a stale tap): leave the next occurrence alone
              model.id != coordinator.firingAlarmID // the in-app firing screen silenced it and owns completion
        else { return }
        coordinator.snoozedInBackground.remove(model.id)
        coordinator.stoppedForCustomSound.remove(model.id)
        coordinator.markHandled(model.id)
        handle(model: model, wasSnoozed: false, context: context)
    }

    /// Snoozed: log it and replace AlarmKit's countdown with a fresh alarm at the snooze expiry,
    /// because a `.fixed()` alarm's countdown never re-alerts. Runs from both the intent and the
    /// `.countdown` update; whichever comes second sees `nextFireDate` in the future and does nothing.
    static func snooze(registrationID: UUID) async {
        guard let (model, context) = model(for: registrationID) else { return }
        let coordinator = AlarmFiringCoordinator.shared
        coordinator.snoozedInBackground.insert(model.id)
        if model.id == coordinator.firingAlarmID {
            coordinator.markHandled(model.id) // so the firing view's onDisappear doesn't log the snooze again
            coordinator.dismissFiring()
        }
        guard model.nextFireDate <= Date() else { return }
        handle(model: model, wasSnoozed: true, context: context)
        do {
            try await AlarmScheduler.shared.scheduleSnoozeRefire(
                id: registrationID, title: model.title, at: model.nextFireDate
            )
        } catch {
            AnalyticsService.shared.recordError(error, context: "snooze_refire_lockScreen")
        }
    }

    static func handle(
        model: Alarm,
        wasSnoozed: Bool,
        context: ModelContext
    ) {
        NotificationService.shared.removeDeliveredNotifications(for: model.id)

        if wasSnoozed {
            // Lock screen snooze
            model.snoozeCount += 1
            model.nextFireDate = Date().addingTimeInterval(540) // matches postAlert snooze duration
            let log = CompletionLog(
                alarmID: model.id,
                scheduledDate: model.nextFireDate,
                action: .snoozed,
                snoozeCount: model.snoozeCount
            )
            log.alarm = model
            context.insert(log)
        } else {
            // System "Done" completes on every tier: the button says Done, so the alarm is done.
            PendingConfirmationService.shared.cancelPending(alarm: model)
            let log = CompletionLog(
                alarmID: model.id,
                scheduledDate: model.nextFireDate,
                action: .completed,
                snoozeCount: model.snoozeCount
            )
            log.alarm = model
            context.insert(log)
            model.lastFiredDate = Date()
            model.lastCompletedAt = Date()
            model.snoozeCount = 0
            if model.cycleType == .oneTime {
                model.isEnabled = false
                model.nextFireDate = .distantFuture
                Task {
                    do { try await AlarmScheduler.shared.cancelAlarm(model) } catch {
                        AnalyticsService.shared.recordError(error, context: "cancel_alarm_lockScreen")
                    }
                }
            } else {
                model.nextFireDate = DateCalculator().calculateNextFireDate(for: model, from: Date())
                Task {
                    do { try await AlarmScheduler.shared.cancelAlarm(model) } catch {
                        AnalyticsService.shared.recordError(error, context: "cancel_alarm_lockScreen")
                    }
                    do { try await AlarmScheduler.shared.scheduleAlarm(model) } catch {
                        AnalyticsService.shared.recordError(error, context: "schedule_alarm_lockScreen")
                    }
                }
            }
            AppReviewService.recordCompletion()
        }
        try? context.save()
        Task {
            await CloudSyncService.shared.pushAlarmModel(model)
            await WidgetDataService.shared.refresh()
            await LiveActivityService.shared.refreshLiveActivity()
        }
    }
}
