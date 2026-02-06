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

    func testWeeklyNextFireDate() {
        // TODO: Implement in Sprint 1
        // Given a weekly alarm set for Monday at 8:00 AM
        // When calculating next fire date from a Tuesday
        // Then should return the following Monday at 8:00 AM
    }

    func testMonthlyLastDayOverflow() {
        // TODO: Implement in Sprint 1
        // Given a monthly alarm set for the 31st
        // When the next month has fewer than 31 days (e.g., February)
        // Then should clamp to the last day of that month
    }

    func testLeapYear() {
        // TODO: Implement in Sprint 1
        // Given a yearly alarm set for February 29
        // When calculating next fire date in a non-leap year
        // Then should handle gracefully (e.g., fire on Feb 28 or March 1)
    }

    func testDSTTransition() {
        // TODO: Implement in Sprint 1
        // Given an alarm set for 2:30 AM
        // When DST spring-forward skips 2:00-3:00 AM
        // Then should adjust the fire time appropriately
    }
}
