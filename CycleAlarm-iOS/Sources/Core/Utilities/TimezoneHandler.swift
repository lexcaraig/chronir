import Foundation

struct TimezoneHandler {
    /// Converts a date from one timezone to another while preserving the wall-clock time.
    func convertPreservingWallTime(
        date: Date,
        from sourceTimeZone: TimeZone,
        to targetTimeZone: TimeZone
    ) -> Date {
        // TODO: Implement in Sprint 2
        fatalError("TODO: Implement convertPreservingWallTime")
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
