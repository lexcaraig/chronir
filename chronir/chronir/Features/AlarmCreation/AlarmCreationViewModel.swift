import Foundation
import Observation
import SwiftData

@Observable
final class AlarmCreationViewModel {
    var title: String = ""
    var cycleType: CycleType = .weekly
    var scheduledTime: Date = Date()
    var isPersistent: Bool = false
    var note: String = ""
    var selectedDays: Set<Int> = [2] // Monday (ISO)
    var daysOfMonth: Set<Int> = [1]
    var category: AlarmCategory?
    var isLoading: Bool = false
    var errorMessage: String?

    private let dateCalculator = DateCalculator()

    func saveAlarm(context: ModelContext) {
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
            category: category?.rawValue,
            note: note.isEmpty ? nil : note
        )

        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())

        context.insert(alarm)

        do {
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func validate() -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func buildSchedule() -> Schedule {
        switch cycleType {
        case .weekly:
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: 1)
        case .monthlyDate:
            return .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: 1)
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
