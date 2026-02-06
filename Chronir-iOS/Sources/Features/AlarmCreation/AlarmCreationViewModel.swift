import Foundation
import Observation

@Observable
final class AlarmCreationViewModel {
    var title: String = ""
    var cycleType: CycleType = .weekly
    var scheduledTime: Date = Date()
    var isPersistent: Bool = false
    var note: String = ""
    var selectedDays: Set<Int> = [2] // Monday (ISO)
    var dayOfMonth: Int = 1
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: AlarmRepositoryProtocol
    private let scheduler: AlarmScheduling
    private let dateCalculator: DateCalculator

    init(
        repository: AlarmRepositoryProtocol = AlarmRepository.shared,
        scheduler: AlarmScheduling = AlarmScheduler.shared,
        dateCalculator: DateCalculator = DateCalculator()
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.dateCalculator = dateCalculator
    }

    func saveAlarm() async {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: scheduledTime)
        let minute = calendar.component(.minute, from: scheduledTime)

        let schedule = buildSchedule()
        let alarm = Alarm(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            cycleType: cycleType,
            timeOfDayHour: hour,
            timeOfDayMinute: minute,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            note: note.isEmpty ? nil : note
        )

        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())

        do {
            try await repository.save(alarm)
            try await scheduler.scheduleAlarm(alarm)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func validate() -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func buildSchedule() -> Schedule {
        switch cycleType {
        case .weekly:
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: 1)
        case .monthlyDate:
            return .monthlyDate(dayOfMonth: dayOfMonth, interval: 1)
        case .monthlyRelative:
            return .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1)
        case .annual:
            let cal = Calendar.current
            return .annual(
                month: cal.component(.month, from: scheduledTime),
                dayOfMonth: cal.component(.day, from: scheduledTime),
                interval: 1
            )
        case .customDays:
            return .customDays(intervalDays: 7, startDate: Date())
        }
    }
}
