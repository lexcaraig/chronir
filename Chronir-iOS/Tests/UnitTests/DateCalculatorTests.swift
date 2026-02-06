import XCTest
@testable import Chronir

final class DateCalculatorTests: XCTestCase {
    private var calculator: DateCalculator!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calculator = DateCalculator(calendar: calendar)
    }

    override func tearDown() {
        calculator = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - Weekly

    func testWeeklyNextMonday() {
        // Tuesday Feb 4 2025 at 10:00 → next Monday (Feb 10) at 8:00
        let tuesday = calendar.date(from: DateComponents(year: 2025, month: 2, day: 4, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .weekly(daysOfWeek: [2], interval: 1) // 2 = Monday (Sun=1 in gregorian)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: tuesday)
        XCTAssertEqual(calendar.component(.weekday, from: next), 2) // Monday
        XCTAssertEqual(calendar.component(.hour, from: next), 8)
        XCTAssertGreaterThan(next, tuesday)
    }

    func testWeeklyMultipleDays() {
        // Monday at 10:00 with Mon/Wed/Fri → next should be Wed at 8:00
        let monday = calendar.date(from: DateComponents(year: 2025, month: 2, day: 3, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .weekly(daysOfWeek: [2, 4, 6], interval: 1) // Mon, Wed, Fri
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: monday)
        XCTAssertEqual(calendar.component(.weekday, from: next), 4) // Wednesday
    }

    func testWeeklySameDayTimePassed() {
        // Monday at 10:00, alarm is for Monday 8:00 → should go to next week
        let monday10am = calendar.date(from: DateComponents(year: 2025, month: 2, day: 3, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: monday10am)
        XCTAssertGreaterThan(next, monday10am)
        XCTAssertEqual(calendar.component(.weekday, from: next), 2)
    }

    func testWeeklySameDayTimeNotPassed() {
        // Monday at 6:00, alarm is for Monday 8:00 → should fire today
        let monday6am = calendar.date(from: DateComponents(year: 2025, month: 2, day: 3, hour: 6, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: monday6am)
        XCTAssertEqual(calendar.component(.day, from: next), 3)
        XCTAssertEqual(calendar.component(.hour, from: next), 8)
    }

    func testBiweeklySkip() {
        // Biweekly (interval=2): should skip one week
        let friday = calendar.date(from: DateComponents(year: 2025, month: 2, day: 7, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .weekly,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .weekly(daysOfWeek: [2], interval: 2) // biweekly Monday
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: friday)
        XCTAssertGreaterThan(next, friday)
        XCTAssertEqual(calendar.component(.weekday, from: next), 2)
    }

    // MARK: - Monthly Date

    func testMonthly15th() {
        // Feb 10 → next is Feb 15
        let feb10 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 10, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .monthlyDate,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .monthlyDate(dayOfMonth: 15, interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: feb10)
        XCTAssertEqual(calendar.component(.day, from: next), 15)
        XCTAssertEqual(calendar.component(.month, from: next), 2)
    }

    func testMonthly31stInFeb() {
        // Jan 31 alarm in Feb → clamps to Feb 28 (non-leap)
        let jan31 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 31, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .monthlyDate,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .monthlyDate(dayOfMonth: 31, interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: jan31)
        XCTAssertEqual(calendar.component(.month, from: next), 2)
        XCTAssertEqual(calendar.component(.day, from: next), 28) // Feb 2025 has 28 days
    }

    func testQuarterly() {
        // Monthly with interval=3 → quarterly
        let jan5 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .monthlyDate,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .monthlyDate(dayOfMonth: 1, interval: 3)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: jan5)
        XCTAssertEqual(calendar.component(.month, from: next), 4) // April
        XCTAssertEqual(calendar.component(.day, from: next), 1)
    }

    // MARK: - Annual

    func testAnnualNextYear() {
        // Mar 20 2025, alarm for Mar 15 → next year Mar 15
        let mar20 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 20, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .annual,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: mar20)
        XCTAssertEqual(calendar.component(.year, from: next), 2026)
        XCTAssertEqual(calendar.component(.month, from: next), 3)
        XCTAssertEqual(calendar.component(.day, from: next), 15)
    }

    func testAnnualFeb29LeapToNonLeap() {
        // Feb 29 alarm in leap year 2024, calculating from Mar 1 2024 → next is Feb 28 2025
        let mar1 = calendar.date(from: DateComponents(year: 2024, month: 3, day: 1, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .annual,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .annual(month: 2, dayOfMonth: 29, interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: mar1)
        XCTAssertEqual(calendar.component(.year, from: next), 2025)
        XCTAssertEqual(calendar.component(.month, from: next), 2)
        XCTAssertEqual(calendar.component(.day, from: next), 28) // Clamped
    }

    // MARK: - Custom Days

    func testCustomDays() {
        // Start Jan 1, every 10 days, from Jan 5 → next is Jan 11
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 0, minute: 0))!
        let jan5 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .customDays,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .customDays(intervalDays: 10, startDate: jan1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: jan5)
        XCTAssertEqual(calendar.component(.day, from: next), 11)
        XCTAssertEqual(calendar.component(.hour, from: next), 8)
    }

    // MARK: - Edge: Time Already Passed Today

    func testTimeAlreadyPassedToday() {
        // Monthly 15th at 8:00, but it's already 10:00 on the 15th → next month
        let feb15at10 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 15, hour: 10, minute: 0))!
        let alarm = Alarm(
            title: "Test",
            cycleType: .monthlyDate,
            timeOfDayHour: 8,
            timeOfDayMinute: 0,
            schedule: .monthlyDate(dayOfMonth: 15, interval: 1)
        )
        let next = calculator.calculateNextFireDate(for: alarm, from: feb15at10)
        XCTAssertEqual(calendar.component(.month, from: next), 3)
        XCTAssertEqual(calendar.component(.day, from: next), 15)
    }

    // MARK: - Helpers

    func testLeapYear() {
        XCTAssertTrue(calculator.isLeapYear(2024))
        XCTAssertFalse(calculator.isLeapYear(2025))
        XCTAssertTrue(calculator.isLeapYear(2000))
        XCTAssertFalse(calculator.isLeapYear(1900))
    }

    func testDaysInMonth() {
        XCTAssertEqual(calculator.daysInMonth(month: 2, year: 2024), 29) // Leap
        XCTAssertEqual(calculator.daysInMonth(month: 2, year: 2025), 28) // Non-leap
        XCTAssertEqual(calculator.daysInMonth(month: 1, year: 2025), 31)
        XCTAssertEqual(calculator.daysInMonth(month: 4, year: 2025), 30)
    }

    func testDSTTransition() {
        // Spring forward: March 9, 2025 in US Eastern
        let tz = TimeZone(identifier: "America/New_York")!
        let march9 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 9))!
        XCTAssertTrue(calculator.isDSTTransition(on: march9, in: tz))

        let march10 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 10))!
        XCTAssertFalse(calculator.isDSTTransition(on: march10, in: tz))
    }
}
