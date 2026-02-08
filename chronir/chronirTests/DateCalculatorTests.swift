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
            schedule: .monthlyDate(dayOfMonth: 15, interval: 1),
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
            schedule: .monthlyDate(dayOfMonth: 31, interval: 1),
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
            schedule: .monthlyDate(dayOfMonth: 29, interval: 1),
            hour: 9, minute: 0
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: from)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 2)
        #expect(components.day == 29)
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
}
