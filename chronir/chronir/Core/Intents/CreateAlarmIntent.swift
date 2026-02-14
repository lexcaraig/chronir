import AppIntents
import Foundation

struct CreateAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Alarm"
    static var description: IntentDescription = "Create a new alarm in Chronir"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Name")
    var name: String

    @Parameter(title: "Schedule Type", default: .weekly)
    var scheduleType: CycleTypeAppEnum

    // Weekly
    @Parameter(title: "Day of Week", default: .monday)
    var dayOfWeek: WeekdayAppEnum

    // Monthly
    @Parameter(title: "Day of Month", default: 1, controlStyle: .stepper, inclusiveRange: (1, 31))
    var dayOfMonth: Int

    // Annual
    @Parameter(title: "Month", default: .january)
    var month: MonthAppEnum

    // One-Time
    @Parameter(title: "Date", description: "Fire date for one-time alarms")
    var fireDate: Date?

    // Shared
    @Parameter(title: "Repeat Every", default: 1, controlStyle: .stepper, inclusiveRange: (1, 52))
    var interval: Int

    @Parameter(title: "Hour", default: 9, controlStyle: .stepper, inclusiveRange: (0, 23))
    var hour: Int

    @Parameter(title: "Minute", default: 0, controlStyle: .stepper, inclusiveRange: (0, 59))
    var minute: Int

    // Plus tier features
    @Parameter(title: "Full-Screen Persistent", default: false)
    var persistent: Bool

    @Parameter(title: "Pre-Alarm Warning", default: false)
    var preAlarmWarning: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let repo = AlarmRepository.shared else {
            throw AlarmIntentError.repositoryUnavailable
        }

        // Check free tier limit
        let tier = SubscriptionService.shared.currentTier
        if tier == .free, let limit = tier.alarmLimit {
            let count = try await repo.countActiveAlarms()
            if count >= limit {
                throw AlarmIntentError.freeTierLimitReached
            }
        }

        // Ask for schedule type
        let chosenType = try await $scheduleType.requestDisambiguation(
            among: CycleTypeAppEnum.allCases,
            dialog: "What type of schedule?"
        )

        // Ask for type-specific fields
        let schedule: Schedule
        var summaryParts: [String] = []

        switch chosenType {
        case .weekly:
            let day = try await $dayOfWeek.requestDisambiguation(
                among: WeekdayAppEnum.allCases,
                dialog: "Which day of the week?"
            )
            interval = try await $interval.requestValue("Repeat every how many weeks?")
            schedule = .weekly(daysOfWeek: [day.rawValue], interval: interval)
            let dayName = String(describing: day).capitalized
            summaryParts.append(interval > 1 ? "every \(interval) weeks on \(dayName)" : "weekly on \(dayName)")

        case .monthly:
            dayOfMonth = try await $dayOfMonth.requestValue("Which day of the month? (1–31)")
            interval = try await $interval.requestValue("Repeat every how many months?")
            schedule = .monthlyDate(daysOfMonth: [dayOfMonth], interval: interval)
            summaryParts.append(interval > 1 ? "every \(interval) months on day \(dayOfMonth)" : "monthly on day \(dayOfMonth)")

        case .annual:
            let chosenMonth = try await $month.requestDisambiguation(
                among: MonthAppEnum.allCases,
                dialog: "Which month?"
            )
            dayOfMonth = try await $dayOfMonth.requestValue("Which day of \(chosenMonth)?")
            interval = try await $interval.requestValue("Repeat every how many years?")
            schedule = .annual(month: chosenMonth.rawValue, dayOfMonth: dayOfMonth, interval: interval)
            let monthName = String(describing: chosenMonth).capitalized
            summaryParts.append(interval > 1 ? "every \(interval) years on \(monthName) \(dayOfMonth)" : "annually on \(monthName) \(dayOfMonth)")

        case .oneTime:
            if fireDate == nil {
                fireDate = try await $fireDate.requestValue("When should the alarm fire?")
            }
            schedule = .oneTime(fireDate: fireDate ?? Date())
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            summaryParts.append("one-time on \(formatter.string(from: fireDate ?? Date()))")
        }

        // Ask for time
        hour = try await $hour.requestValue("What hour? (0–23)")
        minute = try await $minute.requestValue("What minute? (0–59)")

        // Plus tier: persistence and pre-alarm
        let isPlus = tier.rank >= SubscriptionTier.plus.rank
        var persistenceLevel: PersistenceLevel = .notificationOnly
        var preAlarmMinutes = 0

        if isPlus {
            persistent = try await $persistent.requestValue("Make it full-screen persistent?")
            if persistent {
                persistenceLevel = .full
                summaryParts.append("persistent")
            }

            preAlarmWarning = try await $preAlarmWarning.requestValue("Enable 24-hour pre-alarm warning?")
            if preAlarmWarning {
                preAlarmMinutes = 1440
                summaryParts.append("with pre-alarm warning")
            }
        }

        // Sanitize title using the same validation as in-app creation
        let sanitizedName = AlarmValidator.trimmedTitle(name)
        guard !sanitizedName.isEmpty else {
            throw AlarmIntentError.invalidInput
        }

        // Enforce free-tier defaults regardless of parameter values
        if !isPlus {
            persistenceLevel = .notificationOnly
            preAlarmMinutes = 0
        }

        let cycleType = chosenType.toCycleType

        let alarmID = try await repo.createAndSaveAlarm(
            title: sanitizedName,
            cycleType: cycleType,
            schedule: schedule,
            hour: hour,
            minute: minute,
            persistenceLevel: persistenceLevel,
            preAlarmMinutes: preAlarmMinutes
        )

        // Schedule via AlarmKit
        if let alarm = try await repo.fetch(by: alarmID) {
            do {
                try await AlarmScheduler.shared.scheduleAlarm(alarm)
            } catch {
                throw AlarmIntentError.schedulingFailed
            }
        }

        let timeString = String(format: "%d:%02d", hour, minute)
        let details = summaryParts.joined(separator: ", ")
        return .result(dialog: "Created alarm \"\(sanitizedName)\" — \(details) at \(timeString)")
    }
}
