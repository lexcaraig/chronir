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

    func startFiring() {
        isFiring = true
        soundService.startPlaying(soundName: nil)
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

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        if UserSettings.shared.hapticsEnabled { hapticService.playSuccess() }
    }

    // MARK: - Dismiss

    func dismiss() async {
        guard let alarm, !isCompleted else { return }
        isCompleted = true

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.lastFiredDate = Date()
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

        stopFiring()

        await MainActor.run {
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
        } else {
            alarm.lastFiredDate = Date()
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
        }

        // Save on the view's main context (not the actor's background context)
        try? modelContext?.save()
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
