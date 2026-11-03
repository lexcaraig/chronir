import AppIntents
import Foundation
#if !CHRONIR_WIDGET_EXTENSION
import SwiftData
#endif

// Compiled into BOTH the app and the widget extension (widgets need the types for
// `Button(intent:)`). Only the app's copy of `perform()` ever runs: `LiveActivityIntent`
// makes the system execute it in the app process, where AlarmKit and SwiftData live.

struct AlarmEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Alarm"
    static let defaultQuery = AlarmEntityQuery()

    let id: UUID
    let title: String
    let scheduleDisplayName: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(scheduleDisplayName)")
    }
}

struct AlarmEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [AlarmEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [AlarmEntity] {
        #if CHRONIR_WIDGET_EXTENSION
        WidgetDataReader.loadAlarms().map(AlarmEntity.init)
        #else
        guard let repo = AlarmRepository.shared else { throw AlarmIntentError.repositoryUnavailable }
        return try await repo.fetchEnabledSummaries().map {
            AlarmEntity(id: $0.id, title: $0.title, scheduleDisplayName: $0.scheduleDisplayName)
        }
        #endif
    }
}

struct CompleteAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Mark Alarm as Done"
    static let description = IntentDescription("Mark the upcoming occurrence of an alarm as done in Chronir")
    // Completing suppresses an alarm, so never from a locked phone.
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Alarm")
    var alarm: AlarmEntity

    /// The occurrence the widget showed; a stale or repeated tap no-ops instead of completing the next one.
    @Parameter(title: "Expected Fire Date")
    var expectedFireDate: Date?

    init() {}

    init(alarm: AlarmEntity, expectedFireDate: Date? = nil) {
        self.alarm = alarm
        self.expectedFireDate = expectedFireDate
    }

    #if CHRONIR_WIDGET_EXTENSION
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "") // never runs — the system performs LiveActivityIntents in the app
    }
    #else
    /// Test seam: integration tests run on a real (possibly Plus, signed-in) device and must never upload
    /// throwaway alarms to the user's Firestore.
    @MainActor static var syncsToCloud = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let repo = AlarmRepository.shared else { throw AlarmIntentError.repositoryUnavailable }
        let context = repo.modelContainer.mainContext
        let alarmID = alarm.id
        let descriptor = FetchDescriptor<Alarm>(predicate: #Predicate { $0.id == alarmID })
        guard let model = try context.fetch(descriptor).first,
              model.isEnabled, model.nextFireDate != .distantFuture else {
            throw AlarmIntentError.alarmNotFound
        }
        if let expectedFireDate, abs(model.nextFireDate.timeIntervalSince(expectedFireDate)) > 1 {
            await WidgetDataService.shared.refresh()
            return .result(dialog: "\"\(model.title)\" is already done.")
        }

        NotificationService.shared.removeDeliveredNotifications(for: model.id)
        if model.isPendingConfirmation {
            // Already fired and rescheduled; only the confirmation is outstanding.
            PendingConfirmationService.shared.confirmDone(alarm: model)
        } else {
            await Self.completeUpcomingOccurrence(of: model, in: context)
        }
        model.updatedAt = Date()
        try context.save()

        if Self.syncsToCloud {
            Task { await CloudSyncService.shared.pushAlarmModel(model) }
        }
        await WidgetDataService.shared.refresh()
        await LiveActivityService.shared.refreshLiveActivity()
        return .result(dialog: "Marked \"\(model.title)\" as done.")
    }

    /// Completes the occurrence that is due next (it may not have fired yet), then advances
    /// the schedule past it — the same date math as skip, but logged as `.completed`.
    @MainActor
    private static func completeUpcomingOccurrence(of alarm: Alarm, in context: ModelContext) async {
        let now = Date()
        let scheduled = alarm.nextFireDate

        // If this occurrence is alerting or in a snooze countdown, stop it and make sure the
        // firing screen's onDisappear safety net doesn't process it a second time.
        AlarmScheduler.stopActiveRegistration(for: alarm.id)
        AlarmFiringCoordinator.shared.snoozedInBackground.remove(alarm.id)
        AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
        AlarmFiringCoordinator.shared.markHandled(alarm.id)

        let log = CompletionLog(
            alarmID: alarm.id,
            scheduledDate: scheduled,
            completedAt: now,
            action: .completed,
            snoozeCount: alarm.snoozeCount
        )
        log.alarm = alarm
        context.insert(log)

        alarm.lastCompletedAt = now
        alarm.snoozeCount = 0

        let scheduler = AlarmScheduler.shared
        do { try await scheduler.cancelAlarm(alarm) } catch {
            AnalyticsService.shared.recordError(error, context: "cancel_alarm_completeIntent")
        }
        if alarm.cycleType == .oneTime {
            alarm.isEnabled = false
            alarm.nextFireDate = .distantFuture
        } else {
            alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: max(scheduled, now))
            do { try await scheduler.scheduleAlarm(alarm, refreshWidget: false) } catch {
                AnalyticsService.shared.recordError(error, context: "schedule_alarm_completeIntent")
            }
        }
        AppReviewService.recordCompletion()
    }
    #endif
}

#if CHRONIR_WIDGET_EXTENSION
extension AlarmEntity {
    init(_ data: WidgetAlarmData) {
        self.init(id: data.id, title: data.title, scheduleDisplayName: data.scheduleDisplayName)
    }
}
#endif
