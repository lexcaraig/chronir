import Foundation
import Observation
import AlarmKit

@Observable
final class AlarmFiringViewModel {
    var alarm: Alarm?
    var isFiring: Bool = false

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
        hapticService.startAlarmVibrationLoop()
    }

    func stopFiring() {
        isFiring = false
        soundService.stopPlaying()
        hapticService.stopAlarmVibrationLoop()
    }

    // MARK: - Snooze

    func snooze(interval: SnoozeOptionBar.SnoozeInterval) async {
        guard let alarm else { return }

        let seconds: TimeInterval = switch interval {
        case .oneHour: 3600
        case .oneDay: 86400
        case .oneWeek: 604800
        }

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.snoozeCount += 1
        alarm.nextFireDate = Date().addingTimeInterval(seconds)

        try? await scheduler.scheduleAlarm(alarm)

        saveCompletionRecord(alarmID: alarm.id, action: .snoozed)

        if let repo = AlarmRepository.shared {
            try? await repo.update(alarm)
        }

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        hapticService.playSuccess()
    }

    // MARK: - Dismiss

    func dismiss() async {
        guard let alarm else { return }

        try? AlarmManager.shared.stop(id: alarm.id)

        alarm.lastFiredDate = Date()
        alarm.snoozeCount = 0
        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())

        try? await scheduler.cancelAlarm(alarm)
        try? await scheduler.scheduleAlarm(alarm)

        saveCompletionRecord(alarmID: alarm.id, action: .completed)

        if let repo = AlarmRepository.shared {
            try? await repo.update(alarm)
        }

        stopFiring()

        await MainActor.run {
            AlarmFiringCoordinator.shared.dismissFiring()
        }

        hapticService.playSuccess()
    }

    // MARK: - Private

    private func saveCompletionRecord(alarmID: UUID, action: CompletionAction) {
        let record = CompletionRecord(alarmID: alarmID, action: action)
        var records = loadCompletionRecords()
        records.append(record)
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "completionRecords")
        }
    }

    private func loadCompletionRecords() -> [CompletionRecord] {
        guard let data = UserDefaults.standard.data(forKey: "completionRecords"),
              let records = try? JSONDecoder().decode([CompletionRecord].self, from: data) else {
            return []
        }
        return records
    }
}
