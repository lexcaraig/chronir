import Foundation

struct AlarmValidator {
    static let titleMaxLength = 60
    static let noteMaxLength = 500

    // MARK: - Validation Types

    enum ValidationError: Equatable {
        case emptyTitle
    }

    enum ValidationWarning: Equatable {
        case duplicateAlarm(existingTitle: String)
        case sameTimeConflict(existingTitle: String, time: String)
        case monthlyDay31

        var displayMessage: String {
            switch self {
            case .duplicateAlarm(let existingTitle):
                return "\"\(existingTitle)\" has the same name, schedule, and time."
            case .sameTimeConflict(let existingTitle, let time):
                return "\"\(existingTitle)\" also fires at \(time) on overlapping days."
            case .monthlyDay31:
                return "Some months have fewer days. The alarm won't fire on days that don't exist in a given month."
            }
        }
    }

    struct ValidationResult {
        let errors: [ValidationError]
        let warnings: [ValidationWarning]
        var isValid: Bool { errors.isEmpty }
    }

    // MARK: - Core Validation

    // swiftlint:disable:next function_parameter_count
    static func validate(
        title: String,
        note: String,
        cycleType: CycleType,
        schedule: Schedule,
        timesOfDay: [TimeOfDay],
        daysOfMonth: Set<Int>,
        existingAlarms: [Alarm],
        excludingAlarmID: UUID? = nil
    ) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []

        let cleaned = trimmedTitle(title)
        if cleaned.isEmpty {
            errors.append(.emptyTitle)
        }

        guard errors.isEmpty else {
            return ValidationResult(errors: errors, warnings: warnings)
        }

        let candidates = existingAlarms.filter { $0.id != excludingAlarmID }
        let firstTime = timesOfDay.min()

        // Duplicate check: same title (case-insensitive) + same cycle type + same first time
        if let dupe = candidates.first(where: { existing in
            existing.title.localizedCaseInsensitiveCompare(cleaned) == .orderedSame
                && existing.cycleType == cycleType
                && existing.timesOfDay.min() == firstTime
        }) {
            warnings.append(.duplicateAlarm(existingTitle: dupe.title))
        }

        // Same-time conflict: different alarm, same time, overlapping schedule days
        if let firstTime {
            for existing in candidates {
                guard existing.title.localizedCaseInsensitiveCompare(cleaned) != .orderedSame
                    || existing.cycleType != cycleType else { continue }

                let existingTimes = existing.timesOfDay
                guard existingTimes.contains(firstTime) else { continue }

                if schedulesOverlap(schedule, existing.schedule) {
                    warnings.append(.sameTimeConflict(
                        existingTitle: existing.title,
                        time: firstTime.formatted
                    ))
                    break
                }
            }
        }

        // Monthly day-31 warning
        let isMonthly = cycleType == .monthlyDate || cycleType == .monthlyRelative
        if isMonthly, daysOfMonth.contains(where: { $0 > 28 }) {
            warnings.append(.monthlyDay31)
        }

        return ValidationResult(errors: errors, warnings: warnings)
    }

    // MARK: - Sanitization

    static func trimmedTitle(_ title: String) -> String {
        sanitize(title).prefix(titleMaxLength).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func trimmedNote(_ note: String) -> String? {
        let cleaned = sanitize(note).prefix(noteMaxLength).trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    // MARK: - Private

    private static func sanitize(_ input: String) -> String {
        var result = input

        // Strip control characters (keep newlines/tabs for notes)
        result = String(result.unicodeScalars.filter {
            !CharacterSet.controlCharacters
                .subtracting(CharacterSet.newlines)
                .subtracting(CharacterSet(charactersIn: "\t"))
                .contains($0)
        })

        // Strip null bytes
        result = result.replacingOccurrences(of: "\0", with: "")

        // Collapse excessive whitespace runs (more than 2 consecutive newlines → 2)
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result
    }

    private static func schedulesOverlap(_ lhs: Schedule, _ rhs: Schedule) -> Bool {
        switch (lhs, rhs) {
        case (.oneTime, _), (_, .oneTime):
            return false

        case let (.weekly(daysL, _), .weekly(daysR, _)):
            return !Set(daysL).isDisjoint(with: Set(daysR))

        case let (.monthlyDate(daysL, _), .monthlyDate(daysR, _)):
            return !Set(daysL).isDisjoint(with: Set(daysR))

        case let (.annual(monthL, dayL, _), .annual(monthR, dayR, _)):
            return monthL == monthR && dayL == dayR

        default:
            // Different schedule types — no reliable overlap detection
            return false
        }
    }
}
