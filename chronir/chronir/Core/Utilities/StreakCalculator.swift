import Foundation

enum StreakCalculator {
    /// Returns the current consecutive on-time completion streak for an alarm.
    /// Only `.completed` actions count — a snooze or dismiss breaks the streak.
    static func currentStreak(from logs: [CompletionLog]) -> Int {
        let sorted = logs.sorted { $0.completedAt > $1.completedAt }
        var count = 0
        for log in sorted {
            if log.action == .skipped { continue }
            guard log.action == .completed else { break }
            count += 1
        }
        return count
    }

    /// Returns the longest consecutive on-time completion streak for an alarm.
    static func longestStreak(from logs: [CompletionLog]) -> Int {
        let sorted = logs.sorted { $0.completedAt < $1.completedAt }
        var longest = 0
        var current = 0
        for log in sorted {
            if log.action == .skipped { continue }
            if log.action == .completed {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }
}
