import Foundation
import Observation
import AlarmKit
import SwiftData

@Observable
final class AlarmFiringViewModel {
    var alarm: Alarm?
    var isFiring: Bool = false
    /// The view's ModelContext — used to persist changes on the correct (main) context.
    var modelContext: ModelContext?
    private var isCompleted: Bool = false

    private let scheduler: AlarmScheduling
    private let hapticService: HapticServiceProtocol
    private let soundService: AlarmSoundServiceProtocol
    private let dateCalculator: DateCalculator

    init(
        scheduler: AlarmScheduling = AlarmScheduler.shared,
        hapticService: HapticServiceProtocol = HapticService.shared,
        soundService: AlarmSoundServiceProtocol = AlarmSoundService.shared,
        dateCalculator: DateCalculator = DateCalculator()
    ) {
        self.scheduler = scheduler
        self.hapticService = hapticService
        self.soundService = soundService
        self.dateCalculator = dateCalculator
    }

    func loadAlarm(id: UUID) async {
        guard let repo = AlarmRepository.shared else { return }
        alarm = try? await repo.fetch(by: id)
    }

    /// Call `AlarmFiringCoordinator.shared.stoppedForCustomSound.insert(alarm.id)`
    /// from the MainActor call site BEFORE calling this method, so that the
    /// `alarmUpdates` handler doesn't dismiss the firing view when AlarmKit stops.
    func startFiring() {
        isFiring = true
        // Stop AlarmKit's system alarm sound so the user's chosen sound plays instead.
        if let alarm {
            try? AlarmManager.shared.stop(id: alarm.id)
            AnalyticsService.shared.logEvent(AnalyticsEvent.alarmFired, parameters: [
                "cycle_type": alarm.cycleType.rawValue
            ])
        }
        soundService.startPlaying(soundName: alarm?.soundName)
        if UserSettings.shared.hapticsEnabled {
            hapticService.startAlarmVibrationLoop()
        }
    }

    func stopFiring() {
        isFiring = false
        soundService.stopPlaying()
        hapticService.stopAlarmVibrationLoop()
    }

    // MARK: - Snooze

    func snooze(interval: SnoozeOptionBar.SnoozeInterval) async {
        guard let alarm, !isCompleted else { return }
        isCompleted = true

        AnalyticsService.shared.logEvent(AnalyticsEvent.alarmSnoozed, parameters: [
            "snooze_count": alarm.snoozeCount + 1
        ])

        let seconds: TimeInterval = switch interval {
        case .oneHour: 3600
        case .oneDay: 86400
        case .oneWeek: 604800
        case .custom(let duration): duration
        }

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.snoozeCount += 1
        alarm.nextFireDate = Date().addingTimeInterval(seconds)

        try? await scheduler.scheduleAlarm(alarm)

        saveCompletionLog(alarmID: alarm.id, action: .snoozed)

        // Save on the view's main context (not the actor's background context)
        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
            AlarmFiringCoordinator.shared.markHandled(alarm.id)
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        if UserSettings.shared.hapticsEnabled { hapticService.playSuccess() }
    }

    // MARK: - Skip

    func skip() async {
        guard let alarm, !isCompleted else { return }
        guard alarm.cycleType != .oneTime else { return }
        isCompleted = true

        AnalyticsService.shared.logEvent(AnalyticsEvent.alarmSkipped, parameters: [
            "cycle_type": alarm.cycleType.rawValue
        ])

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.snoozeCount = 0
        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: alarm.nextFireDate)

        try? await scheduler.cancelAlarm(alarm)
        try? await scheduler.scheduleAlarm(alarm)

        saveCompletionLog(alarmID: alarm.id, action: .skipped)

        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
            AlarmFiringCoordinator.shared.markHandled(alarm.id)
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        if UserSettings.shared.hapticsEnabled { hapticService.playSuccess() }
    }

    // MARK: - Dismiss

    func dismiss() async {
        guard let alarm, !isCompleted else { return }
        isCompleted = true

        AnalyticsService.shared.logEvent(AnalyticsEvent.alarmCompleted, parameters: [
            "snooze_count": alarm.snoozeCount
        ])

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.lastFiredDate = Date()
        alarm.lastCompletedAt = Date()
        alarm.snoozeCount = 0

        if alarm.cycleType == .oneTime {
            alarm.isEnabled = false
            alarm.nextFireDate = .distantFuture
            try? await scheduler.cancelAlarm(alarm)
        } else {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try? await scheduler.cancelAlarm(alarm)
            try? await scheduler.scheduleAlarm(alarm)
        }

        saveCompletionLog(alarmID: alarm.id, action: .completed)

        // Save on the view's main context (not the actor's background context)
        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }

        stopFiring()

        await MainActor.run {
            // Clear any stale pending state from a previous occurrence
            PendingConfirmationService.shared.cancelPending(alarm: alarm)
            AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
            AlarmFiringCoordinator.shared.markHandled(alarm.id)
            AlarmFiringCoordinator.shared.dismissFiring()
            AppReviewService.recordCompletion()
        }

        if UserSettings.shared.hapticsEnabled { hapticService.playSuccess() }
    }

    // MARK: - Stop (silence alarm, enter pending for Plus)

    func stop() async {
        guard let alarm, !isCompleted else { return }
        isCompleted = true

        try? AlarmManager.shared.stop(id: alarm.id)

        if await MainActor.run(body: { PendingConfirmationService.shared.isPlusUser }) {
            await PendingConfirmationService.shared.enterPending(alarm: alarm)

            AnalyticsService.shared.logEvent(AnalyticsEvent.alarmCompleted, parameters: [
                "snooze_count": alarm.snoozeCount,
                "pending_confirmation": true
            ])
        } else {
            // Free tier — behave like dismiss
            await performDismiss(alarm: alarm)
            return
        }

        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
            AlarmFiringCoordinator.shared.markHandled(alarm.id)
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        if UserSettings.shared.hapticsEnabled { hapticService.playSuccess() }
    }

    // MARK: - Safety Net

    /// Called from onDisappear to ensure the alarm is always completed,
    /// even if dismissed externally (OS banner "X", lock screen stop/snooze).
    func completeIfNeeded() async {
        guard let alarm, !isCompleted else { return }

        // Atomically check-and-set handled state to prevent any double-processing
        let alreadyHandled = await MainActor.run {
            AlarmFiringCoordinator.shared.stoppedForCustomSound.remove(alarm.id)
            if AlarmFiringCoordinator.shared.isHandled(alarm.id) {
                return true
            }
            AlarmFiringCoordinator.shared.markHandled(alarm.id)
            return false
        }
        if alreadyHandled {
            isCompleted = true
            return
        }

        isCompleted = true

        let wasSnoozed = await MainActor.run {
            AlarmFiringCoordinator.shared.snoozedInBackground.remove(alarm.id) != nil
        }

        if wasSnoozed {
            alarm.snoozeCount += 1
            saveCompletionLog(alarmID: alarm.id, action: .snoozed)
        } else if await MainActor.run(body: { PendingConfirmationService.shared.isPlusUser }) {
            // Plus tier safety net: enter pending instead of auto-completing
            await PendingConfirmationService.shared.enterPending(alarm: alarm)
        } else {
            await performDismiss(alarm: alarm)
            return
        }

        // Save on the view's main context (not the actor's background context)
        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }
    }

    /// Shared dismiss logic for Free tier and "Mark as Done" path.
    private func performDismiss(alarm: Alarm) async {
        alarm.lastFiredDate = Date()
        alarm.lastCompletedAt = Date()
        alarm.snoozeCount = 0
        alarm.isPendingConfirmation = false
        alarm.pendingSince = nil

        if alarm.cycleType == .oneTime {
            alarm.isEnabled = false
            alarm.nextFireDate = .distantFuture
            try? await scheduler.cancelAlarm(alarm)
        } else {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try? await scheduler.cancelAlarm(alarm)
            try? await scheduler.scheduleAlarm(alarm)
        }

        saveCompletionLog(alarmID: alarm.id, action: .completed)

        try? modelContext?.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }
    }

    // MARK: - Private

    private func saveCompletionLog(alarmID: UUID, action: CompletionAction) {
        guard let alarm else { return }
        let log = CompletionLog(
            alarmID: alarmID,
            scheduledDate: alarm.nextFireDate,
            action: action,
            snoozeCount: alarm.snoozeCount
        )
        Task {
            if let repo = AlarmRepository.shared {
                try? await repo.saveCompletionLog(log)
            }
        }
    }
}
