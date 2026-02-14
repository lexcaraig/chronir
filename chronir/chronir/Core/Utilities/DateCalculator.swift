import Foundation

struct DateCalculator: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func calculateNextFireDate(for alarm: Alarm, from date: Date) -> Date {
        let times = alarm.timesOfDay.sorted()
        var earliest: Date?
        for time in times {
            let candidate = nextFireDateForSchedule(
                alarm.schedule, from: date,
                hour: time.hour, minute: time.minute
            )
            if earliest == nil || candidate < earliest! {
                earliest = candidate
            }
        }
        return earliest ?? date
    }

    func calculateNextFireDates(for alarm: Alarm, from date: Date) -> [Date] {
        alarm.timesOfDay.sorted().map { time in
            nextFireDateForSchedule(
                alarm.schedule, from: date,
                hour: time.hour, minute: time.minute
            )
        }.sorted()
    }

    private func nextFireDateForSchedule(
        _ schedule: Schedule, from date: Date,
        hour: Int, minute: Int
    ) -> Date {
        switch schedule {
        case .weekly(let daysOfWeek, let interval):
            return nextWeekly(
                from: date, daysOfWeek: daysOfWeek,
                interval: interval, hour: hour, minute: minute
            )
        case .monthlyDate(let daysOfMonth, let interval):
            return nextMonthlyDate(
                from: date, daysOfMonth: daysOfMonth,
                interval: interval, hour: hour, minute: minute
            )
        case .monthlyRelative(let weekOfMonth, let dayOfWeek, let interval):
            return nextMonthlyRelative(
                from: date, weekOfMonth: weekOfMonth,
                dayOfWeek: dayOfWeek, interval: interval,
                hour: hour, minute: minute
            )
        case .annual(let month, let dayOfMonth, let interval):
            return nextAnnual(
                from: date, month: month, dayOfMonth: dayOfMonth,
                interval: interval, hour: hour, minute: minute
            )
        case .customDays(let intervalDays, let startDate):
            return nextCustomDays(
                from: date, intervalDays: intervalDays,
                startDate: startDate, hour: hour, minute: minute
            )
        case .oneTime(let fireDate):
            let candidate = setTime(on: fireDate, hour: hour, minute: minute)
            return candidate > date ? candidate : .distantFuture
        }
    }

    // MARK: - Weekly

    private func nextWeekly(
        from date: Date, daysOfWeek: [Int],
        interval: Int, hour: Int, minute: Int
    ) -> Date {
        guard !daysOfWeek.isEmpty else { return date }

        let currentWeekday = calendar.component(.weekday, from: date)

        // Check each target day this week using modular distance
        // This correctly handles Sunday (1) being later than Tuesday (3)
        // in a Mon-first week by computing actual days-until.
        var candidates: [Date] = []
        for day in daysOfWeek {
            let daysUntil = (day - currentWeekday + 7) % 7
            if daysUntil == 0 {
                // Same weekday — only valid if time hasn't passed
                let candidate = setTime(on: date, hour: hour, minute: minute)
                if candidate > date {
                    candidates.append(candidate)
                }
            } else {
                if let targetDate = calendar.date(byAdding: .day, value: daysUntil, to: date) {
                    candidates.append(setTime(on: targetDate, hour: hour, minute: minute))
                }
            }
        }

        if let earliest = candidates.min() {
            return earliest
        }

        // No match this week — advance by interval weeks from start of current week
        guard let nextWeekStart = calendar.date(
            byAdding: .weekOfYear, value: interval,
            to: startOfWeek(for: date)
        ) else { return date }

        // Find the earliest matching day in that future week
        var futureCandidates: [Date] = []
        for day in daysOfWeek {
            let nextWeekStartWeekday = calendar.component(.weekday, from: nextWeekStart)
            let daysUntil = (day - nextWeekStartWeekday + 7) % 7
            if let targetDate = calendar.date(byAdding: .day, value: daysUntil, to: nextWeekStart) {
                futureCandidates.append(setTime(on: targetDate, hour: hour, minute: minute))
            }
        }
        return futureCandidates.min() ?? date
    }

    // MARK: - Monthly (by date)

    private func nextMonthlyDate(
        from date: Date, daysOfMonth: [Int],
        interval: Int, hour: Int, minute: Int
    ) -> Date {
        guard !daysOfMonth.isEmpty else { return date }

        let sortedDays = daysOfMonth.sorted()
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)

        // Try to find a matching day this month
        for day in sortedDays {
            let clampedDay = clampDay(
                day, month: currentMonth, year: currentYear
            )
            if let candidate = calendar.date(from: DateComponents(
                year: currentYear, month: currentMonth,
                day: clampedDay, hour: hour, minute: minute
            )),
               candidate > date {
                return candidate
            }
        }

        // No match this month — advance by interval months from 1st of current month
        // (avoids month-end overflow when adding months from e.g. the 31st)
        guard let firstOfMonth = calendar.date(from: DateComponents(
            year: currentYear, month: currentMonth, day: 1
        )),
              let nextDate = calendar.date(
                  byAdding: .month, value: interval, to: firstOfMonth
              ) else { return date }
        let nextMonth = calendar.component(.month, from: nextDate)
        let nextYear = calendar.component(.year, from: nextDate)
        let firstDay = sortedDays[0]
        let nextClampedDay = clampDay(
            firstDay, month: nextMonth, year: nextYear
        )

        return calendar.date(from: DateComponents(
            year: nextYear, month: nextMonth,
            day: nextClampedDay, hour: hour, minute: minute
        )) ?? date
    }

    // MARK: - Monthly (relative)

    // swiftlint:disable:next function_parameter_count
    private func nextMonthlyRelative(
        from date: Date, weekOfMonth: Int, dayOfWeek: Int,
        interval: Int, hour: Int, minute: Int
    ) -> Date {
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)

        // Try this month
        if let candidate = nthWeekdayOfMonth(
            weekOfMonth: weekOfMonth, dayOfWeek: dayOfWeek,
            month: currentMonth, year: currentYear,
            hour: hour, minute: minute
        ),
           candidate > date {
            return candidate
        }

        // Move forward by interval months
        guard let nextDate = calendar.date(
            byAdding: .month, value: interval, to: date
        ) else { return date }
        let nextMonth = calendar.component(.month, from: nextDate)
        let nextYear = calendar.component(.year, from: nextDate)

        return nthWeekdayOfMonth(
            weekOfMonth: weekOfMonth, dayOfWeek: dayOfWeek,
            month: nextMonth, year: nextYear,
            hour: hour, minute: minute
        ) ?? date
    }

    // MARK: - Annual

    // swiftlint:disable:next function_parameter_count
    private func nextAnnual(
        from date: Date, month: Int, dayOfMonth: Int,
        interval: Int, hour: Int, minute: Int
    ) -> Date {
        let currentYear = calendar.component(.year, from: date)

        // Try this year
        let clampedDay = clampDay(
            dayOfMonth, month: month, year: currentYear
        )
        if let candidate = calendar.date(from: DateComponents(
            year: currentYear, month: month,
            day: clampedDay, hour: hour, minute: minute
        )),
           candidate > date {
            return candidate
        }

        // Next occurrence (interval years later)
        let nextYear = currentYear + interval
        let nextClampedDay = clampDay(
            dayOfMonth, month: month, year: nextYear
        )
        return calendar.date(from: DateComponents(
            year: nextYear, month: month,
            day: nextClampedDay, hour: hour, minute: minute
        )) ?? date
    }

    // MARK: - Custom Days

    private func nextCustomDays(
        from date: Date, intervalDays: Int,
        startDate: Date, hour: Int, minute: Int
    ) -> Date {
        guard intervalDays > 0 else { return date }

        let startDay = calendar.startOfDay(for: startDate)
        let currentDay = calendar.startOfDay(for: date)

        let daysSinceStart = calendar.dateComponents(
            [.day], from: startDay, to: currentDay
        ).day ?? 0
        let cyclesPassed = daysSinceStart >= 0
            ? daysSinceStart / intervalDays : 0

        // Use Calendar arithmetic instead of TimeInterval * 86400
        // to correctly handle DST transitions (23h or 25h days).
        let totalDaysToNext = (cyclesPassed + 1) * intervalDays
        guard let nextCycleDay = calendar.date(
            byAdding: .day, value: totalDaysToNext, to: startDay
        ) else { return date }

        let candidate = setTime(
            on: nextCycleDay, hour: hour, minute: minute
        )
        if candidate > date {
            return candidate
        }
        guard let followingCycleDay = calendar.date(
            byAdding: .day, value: intervalDays, to: nextCycleDay
        ) else { return date }
        return setTime(
            on: followingCycleDay, hour: hour, minute: minute
        )
    }

    // MARK: - Helpers

    func isDSTTransition(on date: Date, in timeZone: TimeZone) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(
            byAdding: .day, value: 1, to: startOfDay
        ) else { return false }
        let currentOffset = timeZone.daylightSavingTimeOffset(
            for: startOfDay
        )
        let nextOffset = timeZone.daylightSavingTimeOffset(for: nextDay)
        return currentOffset != nextOffset
    }

    private func setTime(
        on date: Date, hour: Int, minute: Int
    ) -> Date {
        calendar.date(
            bySettingHour: hour, minute: minute,
            second: 0, of: date
        ) ?? date
    }

    private func clampDay(
        _ day: Int, month: Int, year: Int
    ) -> Int {
        let daysInMonth = self.daysInMonth(month: month, year: year)
        return min(day, daysInMonth)
    }

    func daysInMonth(month: Int, year: Int) -> Int {
        guard let date = calendar.date(
            from: DateComponents(year: year, month: month, day: 1)
        ),
              let range = calendar.range(
                  of: .day, in: .month, for: date
              ) else {
            return 30
        }
        return range.count
    }

    func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    private func startOfWeek(for date: Date) -> Date {
        var cal = calendar
        cal.firstWeekday = 2 // Monday
        let components = cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: date
        )
        return cal.date(from: components) ?? date
    }

    // swiftlint:disable:next function_parameter_count
    private func nthWeekdayOfMonth(
        weekOfMonth: Int, dayOfWeek: Int,
        month: Int, year: Int,
        hour: Int, minute: Int
    ) -> Date? {
        guard let firstOfMonth = calendar.date(
            from: DateComponents(year: year, month: month, day: 1)
        ) else { return nil }

        if weekOfMonth == -1 {
            // Last occurrence of dayOfWeek in month
            let days = daysInMonth(month: month, year: year)
            guard let lastDay = calendar.date(from: DateComponents(
                year: year, month: month, day: days
            )) else { return nil }
            var current = lastDay
            while calendar.component(.weekday, from: current) != dayOfWeek {
                guard let prev = calendar.date(
                    byAdding: .day, value: -1, to: current
                ) else { return nil }
                current = prev
            }
            return setTime(on: current, hour: hour, minute: minute)
        }

        // Nth occurrence
        var count = 0
        var current = firstOfMonth
        let daysInThisMonth = daysInMonth(month: month, year: year)
        for _ in 1...daysInThisMonth {
            if calendar.component(.weekday, from: current) == dayOfWeek {
                count += 1
                if count == weekOfMonth {
                    return setTime(
                        on: current, hour: hour, minute: minute
                    )
                }
            }
            guard let next = calendar.date(
                byAdding: .day, value: 1, to: current
            ) else { break }
            current = next
        }
        return nil
    }
}
