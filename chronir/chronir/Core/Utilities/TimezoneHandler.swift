import Foundation

struct TimezoneHandler {
    /// Converts a date from one timezone to another while preserving the wall-clock time.
    /// E.g. 9:00 AM in New York becomes 9:00 AM in London (not 2:00 PM).
    func convertPreservingWallTime(
        date: Date,
        from sourceTimeZone: TimeZone,
        to targetTimeZone: TimeZone
    ) -> Date {
        var sourceCal = Calendar.current
        sourceCal.timeZone = sourceTimeZone
        let components = sourceCal.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )

        var targetCal = Calendar.current
        targetCal.timeZone = targetTimeZone
        return targetCal.date(from: components) ?? date
    }

    /// Returns the user's current timezone identifier.
    func currentTimezoneIdentifier() -> String {
        return TimeZone.current.identifier
    }

    /// Detects if the user has changed timezones since a reference date.
    func hasTimezoneChanged(since referenceDate: Date, storedTimezone: String) -> Bool {
        // TODO: Implement in Sprint 2
        return TimeZone.current.identifier != storedTimezone
    }
}
