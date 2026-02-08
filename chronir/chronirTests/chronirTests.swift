import Testing
import Foundation
@testable import chronir

struct TimezoneHandlerTests {
    private let handler = TimezoneHandler()

    @Test func convertPreservingWallTimeSameTimezone() {
        let tz = TimeZone(identifier: "America/New_York")!
        let date = makeDate(2026, 2, 8, 9, 30, in: tz)
        let result = handler.convertPreservingWallTime(date: date, from: tz, to: tz)

        var cal = Calendar.current
        cal.timeZone = tz
        let components = cal.dateComponents([.hour, .minute], from: result)
        #expect(components.hour == 9)
        #expect(components.minute == 30)
    }

    @Test func convertPreservingWallTimeAcrossTimezones() {
        let nyTZ = TimeZone(identifier: "America/New_York")!
        let londonTZ = TimeZone(identifier: "Europe/London")!

        let date = makeDate(2026, 6, 15, 14, 0, in: nyTZ) // 2:00 PM in NY

        let result = handler.convertPreservingWallTime(date: date, from: nyTZ, to: londonTZ)

        var londonCal = Calendar.current
        londonCal.timeZone = londonTZ
        let components = londonCal.dateComponents([.hour, .minute], from: result)
        // Should be 2:00 PM in London (wall time preserved)
        #expect(components.hour == 14)
        #expect(components.minute == 0)
    }

    @Test func convertPreservingWallTimeLargeOffset() {
        let nyTZ = TimeZone(identifier: "America/New_York")!
        let tokyoTZ = TimeZone(identifier: "Asia/Tokyo")!

        let date = makeDate(2026, 3, 10, 8, 0, in: nyTZ) // 8:00 AM in NY

        let result = handler.convertPreservingWallTime(date: date, from: nyTZ, to: tokyoTZ)

        var tokyoCal = Calendar.current
        tokyoCal.timeZone = tokyoTZ
        let components = tokyoCal.dateComponents([.hour, .minute], from: result)
        #expect(components.hour == 8)
        #expect(components.minute == 0)
    }

    @Test func hasTimezoneChangedDetectsChange() {
        let result = handler.hasTimezoneChanged(
            since: Date(), storedTimezone: "Asia/Tokyo"
        )
        // Current timezone is not Asia/Tokyo in test env
        #expect(result == (TimeZone.current.identifier != "Asia/Tokyo"))
    }

    @Test func hasTimezoneChangedNoChange() {
        let currentTZ = TimeZone.current.identifier
        let result = handler.hasTimezoneChanged(
            since: Date(), storedTimezone: currentTZ
        )
        #expect(!result)
    }

    @Test func currentTimezoneIdentifierReturnsNonEmpty() {
        let id = handler.currentTimezoneIdentifier()
        #expect(!id.isEmpty)
    }

    // MARK: - Helpers

    // swiftlint:disable:next function_parameter_count
    private func makeDate(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int, _ minute: Int, in tz: TimeZone
    ) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        return cal.date(from: DateComponents(
            year: year, month: month, day: day,
            hour: hour, minute: minute
        ))!
    }
}
