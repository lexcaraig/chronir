import Foundation

struct DateCalculator: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func calculateNextFireDate(for alarm: Alarm, from date: Date) -> Date {
        let schedule = alarm.schedule
        let hour = alarm.timeOfDayHour
        let minute = alarm.timeOfDayMinute

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
        }
    }

    // MARK: - Weekly

    private func nextWeekly(
        from date: Date, daysOfWeek: [Int],
        interval: Int, hour: Int, minute: Int
    ) -> Date {
        guard !daysOfWeek.isEmpty else { return date }

        let currentWeekday = calendar.component(.weekday, from: date)
        let sortedDays = daysOfWeek.sorted()

        // Try to find a day later this week (or today if time hasn't passed)
        for day in sortedDays {
            if day > currentWeekday {
                if let candidate = dateBySettingWeekday(
                    day, from: date, hour: hour, minute: minute
                ) {
                    return candidate
                }
            } else if day == currentWeekday {
                let candidate = setTime(on: date, hour: hour, minute: minute)
                if candidate > date {
                    return candidate
                }
            }
        }

        // Next week's first matching day (accounting for biweekly+ intervals)
        let weeksToAdd = interval
        guard let nextWeekStart = calendar.date(
            byAdding: .weekOfYear, value: weeksToAdd,
            to: startOfWeek(for: date)
        ),
              let firstDay = sortedDays.first,
              let result = dateBySettingWeekday(
                  firstDay, from: nextWeekStart,
                  hour: hour, minute: minute
              ) else {
            return date
        }
        return result
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

        // No match this month — advance by interval months, pick first sorted day
        guard let nextDate = calendar.date(
            byAdding: .month, value: interval, to: date
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
        let nextCycleDay = startDay.addingTimeInterval(
            Double((cyclesPassed + 1) * intervalDays) * 86400
        )

        let candidate = setTime(
            on: nextCycleDay, hour: hour, minute: minute
        )
        if candidate > date {
            return candidate
        }
        return setTime(
            on: nextCycleDay.addingTimeInterval(
                Double(intervalDays) * 86400
            ),
            hour: hour, minute: minute
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

    func adjustedForMonthEndOverflow(
        date: Date, targetDay: Int
    ) -> Date {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let clamped = clampDay(targetDay, month: month, year: year)
        return calendar.date(
            bySetting: .day, value: clamped, of: date
        ) ?? date
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

    private func dateBySettingWeekday(
        _ weekday: Int, from date: Date,
        hour: Int, minute: Int
    ) -> Date? {
        let currentWeekday = calendar.component(.weekday, from: date)
        let daysToAdd = (weekday - currentWeekday + 7) % 7
        guard let targetDate = calendar.date(
            byAdding: .day,
            value: daysToAdd == 0 ? 7 : daysToAdd, to: date
        ) else { return nil }
        return setTime(on: targetDate, hour: hour, minute: minute)
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
