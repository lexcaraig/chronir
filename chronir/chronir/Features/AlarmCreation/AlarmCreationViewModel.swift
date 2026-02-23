import Foundation
import Observation
import SwiftData

@Observable
final class AlarmCreationViewModel {
    var title: String = ""
    var cycleType: CycleType = .weekly
    var repeatInterval: Int = 1
    var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    var isPersistent: Bool = false
    var note: String = ""
    var selectedDays: Set<Int> = [2] // Monday (ISO)
    var daysOfMonth: Set<Int> = [1]
    var annualMonth: Int = Calendar.current.component(.month, from: Date())
    var annualDay: Int = Calendar.current.component(.day, from: Date())
    var annualYear: Int = Calendar.current.component(.year, from: Date())
    var startMonth: Int = Calendar.current.component(.month, from: Date())
    var startYear: Int = Calendar.current.component(.year, from: Date())
    var category: AlarmCategory?
    var oneTimeDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var isLoading: Bool = false
    var errorMessage: String?

    private let dateCalculator = DateCalculator()

    func saveAlarm(context: ModelContext) {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }

        let schedule = buildSchedule()
        let alarm = Alarm(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            category: category?.rawValue,
            note: note.isEmpty ? nil : note
        )

        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())

        context.insert(alarm)

        do {
            try context.save()
            AnalyticsService.shared.logEvent(AnalyticsEvent.alarmCreated, parameters: [
                "cycle_type": cycleType.rawValue,
                "tier": SubscriptionService.shared.currentTier.rawValue
            ])
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
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: repeatInterval)
        case .monthlyDate:
            return .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: repeatInterval)
        case .monthlyRelative:
            return .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: repeatInterval)
        case .annual:
            return .annual(
                month: annualMonth,
                dayOfMonth: annualDay,
                interval: repeatInterval
            )
        case .customDays:
            return .customDays(intervalDays: repeatInterval, startDate: Date())
        case .oneTime:
            return .oneTime(fireDate: oneTimeDate)
        }
    }
}
