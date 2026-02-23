import Testing
import Foundation
@testable import chronir

struct DateCalculatorTests {
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal
    }()

    private var calculator: DateCalculator {
        DateCalculator(calendar: calendar)
    }

    private func date(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int = 0, _ minute: Int = 0
    ) -> Date {
        calendar.date(from: DateComponents(
            year: year, month: month, day: day,
            hour: hour, minute: minute
        ))!
    }

    // MARK: - Weekly

    @Test func weeklyNextDaySameWeek() {
        // Wednesday at 10:00, alarm for Friday (weekday 6) at 9:00
        let from = date(2026, 2, 4, 10, 0) // Wednesday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [6], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: next)
        #expect(components.weekday == 6)
        #expect(components.hour == 9)
        #expect(next > from)
    }

    @Test func weeklySameDayTimePassed() {
        // Monday at 10:00, alarm for Monday at 9:00 → next week
        let from = date(2026, 2, 2, 10, 0)
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next > from)
        let components = calendar.dateComponents([.weekday, .hour], from: next)
        #expect(components.weekday == 2)
        #expect(components.hour == 9)
    }

    @Test func weeklySameDayTimeNotPassed() {
        // Monday at 8:00, alarm for Monday at 9:00 → today
        let from = date(2026, 2, 2, 8, 0)
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: next)
        #expect(components.day == 2)
        #expect(components.hour == 9)
    }

    @Test func weeklyBiweeklyInterval() {
        // Saturday at 10:00, alarm for Monday every 2 weeks
        let from = date(2026, 2, 7, 10, 0) // Saturday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [2], interval: 2),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next > from)
        let components = calendar.dateComponents([.weekday], from: next)
        #expect(components.weekday == 2)
    }

    // MARK: - Monthly (by date)

    @Test func monthlyDateNormalDay() {
        // Feb 1 at 10:00, alarm on 15th at 9:00 → Feb 15
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [15], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 2)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    @Test func monthlyDate31stInFebruary() {
        // Jan 31 at 10:00, alarm on 31st → Feb 28 (2026 is not leap year)
        let from = date(2026, 1, 31, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 2)
        #expect(components.day == 28)
    }

    @Test func monthlyDate29thLeapYear() {
        // Feb 1 2028 (leap year), alarm on 29th → Feb 29
        let from = date(2028, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [29], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }

    @Test func monthlyDateMultipleDaysPicksNextInMonth() {
        // Feb 10 at 10:00, alarm on [5, 15, 25] → Feb 15
        let from = date(2026, 2, 10, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [5, 15, 25], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 2)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    @Test func monthlyDateMultipleDaysAllPassedThisMonth() {
        // Feb 26 at 10:00, alarm on [5, 15, 25] → March 5
        let from = date(2026, 2, 26, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [5, 15, 25], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 3)
        #expect(components.day == 5)
    }

    @Test func monthlyDateMultipleDaysWithMonthEndClamping() {
        // Jan 30 at 10:00, alarm on [28, 31] → Jan 31
        let from = date(2026, 1, 30, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [28, 31], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func monthlyDateSameDayTimeNotPassed() {
        // Feb 15 at 8:00, alarm on [15] at 9:00 → Feb 15 9:00
        let from = date(2026, 2, 15, 8, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [15], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 2)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    // MARK: - Monthly (relative)

    @Test func monthlyRelativeFirstMonday() {
        // Feb 1 2026 at 10:00, 1st Monday (weekday 2) → Feb 2
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .weekday], from: next)
        #expect(components.weekday == 2)
        #expect(components.month == 2)
        #expect(components.day == 2)
    }

    @Test func monthlyRelativeLastFriday() {
        // Feb 1 2026 at 10:00, last Friday (weekday 6, weekOfMonth -1) → Feb 27
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyRelative(weekOfMonth: -1, dayOfWeek: 6, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .weekday], from: next)
        #expect(components.weekday == 6)
        #expect(components.month == 2)
        #expect(components.day == 27)
    }

    // MARK: - Annual

    @Test func annualNormalDate() {
        // Jan 1 2026, alarm on March 15 → Mar 15 2026
        let from = date(2026, 1, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    @Test func annualFeb29NonLeapYear() {
        // After Feb 29 2028 (leap year), alarm for Feb 29 → 2029 clamps to Feb 28
        let from = date(2028, 3, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .annual(month: 2, dayOfMonth: 29, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2029)
        #expect(components.month == 2)
        #expect(components.day == 28)
    }

    @Test func annualDateAlreadyPassed() {
        // After Mar 15 2026, alarm on Mar 15 → Mar 15 2027
        let from = date(2026, 3, 16, 10, 0)
        let alarm = makeAlarm(
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2027)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Custom Days

    @Test func customDaysInterval() {
        let startDate = date(2026, 1, 1)
        let from = date(2026, 1, 10, 10, 0)
        let alarm = makeAlarm(
            schedule: .customDays(intervalDays: 7, startDate: startDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next > from)
        let components = calendar.dateComponents([.hour, .minute], from: next)
        #expect(components.hour == 9)
        #expect(components.minute == 0)
    }

    // MARK: - Helpers

    @Test func isLeapYear() {
        #expect(calculator.isLeapYear(2024))
        #expect(calculator.isLeapYear(2028))
        #expect(!calculator.isLeapYear(2026))
        #expect(!calculator.isLeapYear(2100))
        #expect(calculator.isLeapYear(2000))
    }

    @Test func daysInMonth() {
        #expect(calculator.daysInMonth(month: 2, year: 2026) == 28)
        #expect(calculator.daysInMonth(month: 2, year: 2028) == 29)
        #expect(calculator.daysInMonth(month: 1, year: 2026) == 31)
        #expect(calculator.daysInMonth(month: 4, year: 2026) == 30)
    }

    @Test func isDSTTransition() {
        let tz = TimeZone(identifier: "America/New_York")!
        // March 8 2026: DST spring forward
        let springForward = date(2026, 3, 8)
        #expect(calculator.isDSTTransition(on: springForward, in: tz))

        // Regular day
        let normal = date(2026, 6, 15)
        #expect(!calculator.isDSTTransition(on: normal, in: tz))
    }

    // MARK: - Multiple Times Per Day

    @Test func multipleTimesPicksEarliestNextFire() {
        // 10:00 AM, alarm with times [9:00, 12:00, 17:00] → next is 12:00
        let from = date(2026, 2, 4, 10, 0) // Wednesday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [4], interval: 1), // Wednesday
            timesOfDay: [
                TimeOfDay(hour: 9, minute: 0),
                TimeOfDay(hour: 12, minute: 0),
                TimeOfDay(hour: 17, minute: 0)
            ]
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.hour, .minute], from: next)
        #expect(components.hour == 12)
        #expect(components.minute == 0)
    }

    @Test func multipleTimesAllPassedToday() {
        // 13:00, alarm with times [9:00, 12:00] on Wednesday → next Wednesday 9:00
        let from = date(2026, 2, 4, 13, 0) // Wednesday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [4], interval: 1),
            timesOfDay: [
                TimeOfDay(hour: 9, minute: 0),
                TimeOfDay(hour: 12, minute: 0)
            ]
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next > from)
        let components = calendar.dateComponents([.weekday, .hour], from: next)
        #expect(components.weekday == 4)
        #expect(components.hour == 9)
    }

    @Test func multipleTimesNextFireDatesReturnsAll() {
        let from = date(2026, 2, 4, 10, 0) // Wednesday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [4], interval: 1),
            timesOfDay: [
                TimeOfDay(hour: 9, minute: 0),
                TimeOfDay(hour: 12, minute: 0),
                TimeOfDay(hour: 17, minute: 0)
            ]
        )
        let dates = calculator.calculateNextFireDates(for: alarm, from: from)
        #expect(dates.count == 3)
        // Should be sorted
        #expect(dates[0] < dates[1])
        #expect(dates[1] < dates[2])
    }

    @Test func singleTimeBackwardCompat() {
        // Single-time alarm should produce same result as before
        let from = date(2026, 2, 4, 10, 0) // Wednesday
        let alarmLegacy = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 9,
            timeOfDayMinute: 30,
            schedule: .weekly(daysOfWeek: [6], interval: 1)
        )
        let alarmMulti = makeAlarm(
            schedule: .weekly(daysOfWeek: [6], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 30)]
        )
        let nextLegacy = calculator.calculateNextFireDate(for: alarmLegacy, from: from)
        let nextMulti = calculator.calculateNextFireDate(for: alarmMulti, from: from)
        #expect(nextLegacy == nextMulti)
    }

    // MARK: - One-Time

    @Test func oneTimeFutureDate() {
        let from = date(2026, 2, 1, 10, 0)
        let fireDate = date(2026, 3, 15)
        let alarm = makeAlarm(
            schedule: .oneTime(fireDate: fireDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: next)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    @Test func oneTimePastDateReturnsDistantFuture() {
        let from = date(2026, 4, 1, 10, 0)
        let fireDate = date(2026, 3, 15)
        let alarm = makeAlarm(
            schedule: .oneTime(fireDate: fireDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next == .distantFuture)
    }

    @Test func oneTimeTodayTimeNotPassed() {
        let from = date(2026, 3, 15, 8, 0)
        let fireDate = date(2026, 3, 15)
        let alarm = makeAlarm(
            schedule: .oneTime(fireDate: fireDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.day, .hour], from: next)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    // MARK: - Weekly (additional)

    @Test func weeklyMultiDayPicksNearest() {
        // Wednesday at 10:00, alarm for Mon(2)+Wed(4)+Fri(6) at 9:00
        // Wed time passed → nearest is Friday
        let from = date(2026, 2, 4, 10, 0) // Wednesday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [2, 4, 6], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.weekday, .hour], from: next)
        #expect(components.weekday == 6)
        #expect(components.hour == 9)
    }

    @Test func weeklyEachDayOfWeekFiresCorrectly() {
        // Sunday Feb 1 2026 at 10:00 — test each weekday 1-7
        let from = date(2026, 2, 1, 10, 0) // Sunday
        for weekday in 1...7 {
            let alarm = makeAlarm(
                schedule: .weekly(daysOfWeek: [weekday], interval: 1),
                hour: 9, minute: 0
            )
            let next = calculator.calculateNextFireDate(for: alarm, from: from)
            let components = calendar.dateComponents([.weekday, .hour], from: next)
            #expect(components.weekday == weekday)
            #expect(components.hour == 9)
            #expect(next > from)
        }
    }

    @Test func weeklyFridayTimePassedAdvancesToNextWeek() {
        // Friday at 10:00, alarm for Friday at 9:00 → next Friday
        let from = date(2026, 2, 6, 10, 0) // Friday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [6], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.weekday, .day, .hour], from: next)
        #expect(components.weekday == 6)
        #expect(components.day == 13)
        #expect(components.hour == 9)
    }

    @Test func weeklyTriweeklyInterval() {
        // Monday at 10:00, alarm for Wednesday every 3 weeks
        let from = date(2026, 2, 2, 10, 0) // Monday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [4], interval: 3),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next > from)
        let components = calendar.dateComponents([.weekday, .hour], from: next)
        #expect(components.weekday == 4)
        #expect(components.hour == 9)
    }

    // MARK: - Monthly by Date (additional)

    @Test func monthlyDate30thInFebruary() {
        // Jan 31 at 10:00, alarm on 30th → Feb 28 (2026 non-leap)
        let from = date(2026, 1, 31, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [30], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 2)
        #expect(components.day == 28)
    }

    @Test func monthlyDate31stIn30DayMonth() {
        // Mar 31 at 10:00, alarm on 31st → April 30 (April has 30 days)
        let from = date(2026, 3, 31, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 4)
        #expect(components.day == 30)
    }

    @Test func monthlyDateBimonthlyInterval() {
        // Feb 20 at 10:00, alarm on 15th every 2 months → April 15
        let from = date(2026, 2, 20, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [15], interval: 2),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 4)
        #expect(components.day == 15)
    }

    // MARK: - Monthly Relative (additional)

    @Test func monthlyRelativeSecondWednesday() {
        // Feb 1 2026 at 10:00, 2nd Wednesday (weekday 4) → Feb 11
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyRelative(weekOfMonth: 2, dayOfWeek: 4, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .weekday], from: next)
        #expect(components.weekday == 4)
        #expect(components.month == 2)
        #expect(components.day == 11)
    }

    @Test func monthlyRelativeLastDayOnBoundary() {
        // Oct 1 2026 — last Saturday (weekday 7)
        // Oct 2026: 31 days. Oct 31 = Saturday
        let from = date(2026, 10, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyRelative(weekOfMonth: -1, dayOfWeek: 7, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .weekday], from: next)
        #expect(components.weekday == 7)
        #expect(components.month == 10)
        #expect(components.day == 31)
    }

    @Test func monthlyRelativeFourthFriday() {
        // Feb 1 2026, 4th Friday (weekday 6) → Feb 27
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .monthlyRelative(weekOfMonth: 4, dayOfWeek: 6, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .weekday], from: next)
        #expect(components.weekday == 6)
        #expect(components.month == 2)
        #expect(components.day == 27)
    }

    // MARK: - Annual (additional)

    @Test func annualFeb29LeapToNonLeap() {
        // Feb 1 2028 (leap year), alarm for Feb 29 — fires Feb 29 2028.
        // Then from Mar 1 2028, next is Feb 28 2029 (non-leap, clamped).
        let from = date(2028, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .annual(month: 2, dayOfMonth: 29, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2028)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }

    @Test func annualBiannualInterval() {
        // After Mar 15 2026, alarm on Mar 15 every 2 years → Mar 15 2028
        let from = date(2026, 3, 16, 10, 0)
        let alarm = makeAlarm(
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 2),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2028)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Custom Days (additional)

    @Test func customDaysDaily() {
        // Interval of 1 day (daily), start Jan 1, from Jan 10 at 10:00
        let startDate = date(2026, 1, 1)
        let from = date(2026, 1, 10, 10, 0)
        let alarm = makeAlarm(
            schedule: .customDays(intervalDays: 1, startDate: startDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 1)
        #expect(components.day == 11)
        #expect(components.hour == 9)
    }

    @Test func customDaysLargeInterval() {
        // 365-day interval, start Jan 1 2026, from Jan 2 2026
        let startDate = date(2026, 1, 1)
        let from = date(2026, 1, 2, 10, 0)
        let alarm = makeAlarm(
            schedule: .customDays(intervalDays: 365, startDate: startDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day], from: next)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 1)
    }

    @Test func customDaysFutureStartDate() {
        // Start date in the future — first fire is startDate + intervalDays
        // (the algorithm treats startDate as cycle anchor, not a fire date)
        let startDate = date(2026, 6, 15)
        let from = date(2026, 2, 1, 10, 0)
        let alarm = makeAlarm(
            schedule: .customDays(intervalDays: 30, startDate: startDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: next)
        #expect(components.month == 7)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    // MARK: - DST Transition Tests

    @Test func dstSpringForwardAlarmAt230AM() {
        // Mar 8 2026 spring forward in America/New_York (2:00 AM → 3:00 AM)
        // Alarm at 2:30 AM — time doesn't exist, Calendar adjusts
        // Use weekly schedule so Mar 8 (Sunday, weekday 1) is the next fire date
        let from = date(2026, 3, 7, 10, 0) // Saturday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [1], interval: 1),
            hour: 2, minute: 30
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        // Should still fire on Mar 8 (Calendar handles the nonexistent time)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 3)
        #expect(components.day == 8)
        #expect(next > from)
    }

    @Test func dstFallBackAlarmAt130AM() {
        // Nov 1 2026 fall back in America/New_York (2:00 AM → 1:00 AM)
        // Alarm at 1:30 AM — ambiguous time, should still fire
        // Use weekly schedule so Nov 1 (Sunday, weekday 1) is the next fire date
        let from = date(2026, 10, 31, 10, 0) // Saturday
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [1], interval: 1),
            hour: 1, minute: 30
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 11)
        #expect(components.day == 1)
        #expect(next > from)
    }

    @Test func dstWeeklyCrossingSpringForward() {
        // Friday Mar 6 2026, alarm on Friday at 9:00, DST on Mar 8
        // Next Friday = Mar 13 — should still be 9:00 AM
        let from = date(2026, 3, 6, 10, 0)
        let alarm = makeAlarm(
            schedule: .weekly(daysOfWeek: [6], interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 3)
        #expect(components.day == 13)
        #expect(components.hour == 9)
    }

    @Test func dstCustomDaysCrossingSpringForward() {
        // Every 7 days from Mar 1 2026, from Mar 5 at 10:00
        // Next cycle: Mar 8 (DST day), still correct date and time
        let startDate = date(2026, 3, 1)
        let from = date(2026, 3, 5, 10, 0)
        let alarm = makeAlarm(
            schedule: .customDays(intervalDays: 7, startDate: startDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 3)
        #expect(components.day == 8)
        #expect(components.hour == 9)
    }

    // MARK: - Edge Cases

    @Test func oneTimeBoundaryOneSecondAgo() {
        // One-time alarm at exactly 9:00, current time is 9:00 (same minute)
        // date() sets seconds to 0, so same time → not > date → distantFuture
        let from = date(2026, 3, 15, 9, 0)
        let fireDate = date(2026, 3, 15)
        let alarm = makeAlarm(
            schedule: .oneTime(fireDate: fireDate),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        #expect(next == .distantFuture)
    }

    @Test func midnightBoundaryAlarm() {
        // Alarm at 00:00 on a specific day
        let from = date(2026, 2, 14, 23, 59)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [15], interval: 1),
            hour: 0, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: next)
        #expect(components.month == 2)
        #expect(components.day == 15)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
    }

    @Test func multipleTimesAllPassedMonthly() {
        // Monthly on 15th, times [9:00, 12:00], current is Feb 15 at 13:00
        // All times passed → next month March 15 at 9:00
        let from = date(2026, 2, 15, 13, 0)
        let alarm = makeAlarm(
            schedule: .monthlyDate(daysOfMonth: [15], interval: 1),
            timesOfDay: [
                TimeOfDay(hour: 9, minute: 0),
                TimeOfDay(hour: 12, minute: 0)
            ]
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day, .hour], from: next)
        #expect(components.month == 3)
        #expect(components.day == 15)
        #expect(components.hour == 9)
    }

    @Test func oneTimeSameDayEarlierTime() {
        // One-time today, alarm time hasn't passed yet
        let from = date(2026, 3, 15, 7, 59)
        let fireDate = date(2026, 3, 15)
        let alarm = makeAlarm(
            schedule: .oneTime(fireDate: fireDate),
            hour: 8, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.day, .hour, .minute], from: next)
        #expect(components.day == 15)
        #expect(components.hour == 8)
        #expect(components.minute == 0)
    }

    // MARK: - Helpers (additional)

    @Test func daysInMonthAllTwelveMonths() {
        let expected = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for month in 1...12 {
            #expect(
                calculator.daysInMonth(month: month, year: 2026) == expected[month - 1]
            )
        }
    }

    @Test func isLeapYearCenturyBoundaries() {
        #expect(!calculator.isLeapYear(1900)) // divisible by 100 but not 400
        #expect(calculator.isLeapYear(2000))  // divisible by 400
        #expect(!calculator.isLeapYear(2100)) // divisible by 100 but not 400
        #expect(calculator.isLeapYear(2400))  // divisible by 400
    }

    // MARK: - Factory

    private func makeAlarm(
        schedule: Schedule, hour: Int, minute: Int
    ) -> Alarm {
        Alarm(
            title: "Test",
            cycleType: schedule.cycleType,
            timeOfDayHour: hour,
            timeOfDayMinute: minute,
            schedule: schedule
        )
    }

    private func makeAlarm(
        schedule: Schedule, timesOfDay: [TimeOfDay]
    ) -> Alarm {
        Alarm(
            title: "Test",
            cycleType: schedule.cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule
        )
    }
}
