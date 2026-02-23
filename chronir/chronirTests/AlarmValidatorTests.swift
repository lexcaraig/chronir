import Testing
import Foundation
@testable import chronir

struct AlarmValidatorTests {

    // MARK: - Factory

    private func makeAlarm(
        id: UUID = UUID(),
        title: String = "Test",
        cycleType: CycleType = .weekly,
        timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)],
        schedule: Schedule = .weekly(daysOfWeek: [2], interval: 1)
    ) -> Alarm {
        Alarm(
            id: id,
            title: title,
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule
        )
    }

    private func validate(
        title: String = "Test Alarm",
        note: String = "",
        cycleType: CycleType = .weekly,
        schedule: Schedule = .weekly(daysOfWeek: [2], interval: 1),
        timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)],
        daysOfMonth: Set<Int> = [],
        existingAlarms: [Alarm] = [],
        excludingAlarmID: UUID? = nil
    ) -> AlarmValidator.ValidationResult {
        AlarmValidator.validate(
            title: title,
            note: note,
            cycleType: cycleType,
            schedule: schedule,
            timesOfDay: timesOfDay,
            daysOfMonth: daysOfMonth,
            existingAlarms: existingAlarms,
            excludingAlarmID: excludingAlarmID
        )
    }

    // MARK: - Empty Title Validation

    @Test func emptyTitleReturnsError() {
        let result = validate(title: "")
        #expect(!result.isValid)
        #expect(result.errors.contains(.emptyTitle))
    }

    @Test func whitespaceOnlyTitleReturnsError() {
        let result = validate(title: "   ")
        #expect(!result.isValid)
        #expect(result.errors.contains(.emptyTitle))
    }

    @Test func validTitleReturnsNoErrors() {
        let result = validate(title: "Morning Alarm")
        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    // MARK: - Title Trimming

    @Test func trimmedTitleStripsLeadingAndTrailingWhitespace() {
        let trimmed = AlarmValidator.trimmedTitle("  Hello World  ")
        #expect(trimmed == "Hello World")
    }

    @Test func trimmedTitleTruncatesTo60Characters() {
        let longTitle = String(repeating: "A", count: 80)
        let trimmed = AlarmValidator.trimmedTitle(longTitle)
        #expect(trimmed.count == 60)
    }

    @Test func trimmedTitleLeavesNormalTitleUnchanged() {
        let title = "Pay Rent"
        let trimmed = AlarmValidator.trimmedTitle(title)
        #expect(trimmed == "Pay Rent")
    }

    @Test func trimmedTitleExactly60CharsUnchanged() {
        let title = String(repeating: "B", count: 60)
        let trimmed = AlarmValidator.trimmedTitle(title)
        #expect(trimmed.count == 60)
        #expect(trimmed == title)
    }

    // MARK: - Note Trimming

    @Test func trimmedNoteEmptyReturnsNil() {
        let note = AlarmValidator.trimmedNote("")
        #expect(note == nil)
    }

    @Test func trimmedNoteWhitespaceOnlyReturnsNil() {
        let note = AlarmValidator.trimmedNote("   \n  \t  ")
        #expect(note == nil)
    }

    @Test func trimmedNoteNormalStringReturnsTrimmed() {
        let note = AlarmValidator.trimmedNote("  Remember to call first  ")
        #expect(note == "Remember to call first")
    }

    @Test func trimmedNoteTruncatesTo500Characters() {
        let longNote = String(repeating: "N", count: 600)
        let note = AlarmValidator.trimmedNote(longNote)
        #expect(note != nil)
        #expect(note!.count == 500)
    }

    @Test func trimmedNoteExactly500CharsUnchanged() {
        let note500 = String(repeating: "X", count: 500)
        let note = AlarmValidator.trimmedNote(note500)
        #expect(note == note500)
    }

    // MARK: - Sanitization

    @Test func sanitizeStripsControlCharactersButKeepsNewlinesAndTabs() {
        // Bell character (\u{07}) is a control character that should be stripped
        let input = "Hello\u{07}World\nLine2\tTabbed"
        let trimmed = AlarmValidator.trimmedTitle(input)
        #expect(!trimmed.contains("\u{07}"))
        // Newlines get trimmed by trimmingCharacters on the ends,
        // but internal newlines/tabs should survive sanitize
    }

    @Test func sanitizeStripsNullBytes() {
        let input = "Hello\0World"
        let trimmed = AlarmValidator.trimmedTitle(input)
        #expect(!trimmed.contains("\0"))
        #expect(trimmed == "HelloWorld")
    }

    @Test func sanitizeCollapsesTripleNewlinesToDouble() {
        let input = "Line1\n\n\nLine2"
        let note = AlarmValidator.trimmedNote(input)
        #expect(note != nil)
        #expect(!note!.contains("\n\n\n"))
        #expect(note!.contains("\n\n"))
    }

    @Test func sanitizePreservesDoubleNewlines() {
        let input = "Line1\n\nLine2"
        let note = AlarmValidator.trimmedNote(input)
        #expect(note != nil)
        #expect(note!.contains("\n\n"))
    }

    @Test func sanitizeCollapsesFourNewlinesToDouble() {
        let input = "A\n\n\n\nB"
        let note = AlarmValidator.trimmedNote(input)
        #expect(note != nil)
        #expect(!note!.contains("\n\n\n"))
    }

    // MARK: - Duplicate Alarm Warning

    @Test func duplicateAlarmSameTitleCycleAndTime() {
        let existing = makeAlarm(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .monthlyDate(daysOfMonth: [1], interval: 1)
        )
        let result = validate(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [1], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(hasDuplicate)
    }

    @Test func duplicateAlarmCaseInsensitive() {
        let existing = makeAlarm(
            title: "pay rent",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "PAY RENT",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            existingAlarms: [existing]
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(hasDuplicate)
    }

    @Test func noDuplicateWarningDifferentTitle() {
        let existing = makeAlarm(
            title: "Pay Rent",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "Water Plants",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            existingAlarms: [existing]
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(!hasDuplicate)
    }

    @Test func noDuplicateWarningDifferentCycleType() {
        let existing = makeAlarm(
            title: "Pay Rent",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [1], interval: 1),
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            existingAlarms: [existing]
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(!hasDuplicate)
    }

    @Test func noDuplicateWarningDifferentTime() {
        let existing = makeAlarm(
            title: "Pay Rent",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "Pay Rent",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            timesOfDay: [TimeOfDay(hour: 10, minute: 30)],
            existingAlarms: [existing]
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(!hasDuplicate)
    }

    @Test func excludingAlarmIDSkipsSelfNoDuplicateOnEdit() {
        let alarmID = UUID()
        let existing = makeAlarm(
            id: alarmID,
            title: "Pay Rent",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "Pay Rent",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            timesOfDay: [TimeOfDay(hour: 8, minute: 0)],
            existingAlarms: [existing],
            excludingAlarmID: alarmID
        )
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        #expect(!hasDuplicate)
    }

}

// MARK: - Same-Time Conflict, Monthly, Combined, Edge Cases

extension AlarmListValidatorConflictTests {
    private func makeAlarm(
        id: UUID = UUID(),
        title: String = "Test",
        cycleType: CycleType = .weekly,
        timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)],
        schedule: Schedule = .weekly(daysOfWeek: [2], interval: 1)
    ) -> Alarm {
        Alarm(
            id: id,
            title: title,
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule
        )
    }

    private func validate(
        title: String = "Test Alarm",
        note: String = "",
        cycleType: CycleType = .weekly,
        schedule: Schedule = .weekly(daysOfWeek: [2], interval: 1),
        timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)],
        daysOfMonth: Set<Int> = [],
        existingAlarms: [Alarm] = []
    ) -> AlarmValidator.ValidationResult {
        AlarmValidator.validate(
            title: title,
            note: note,
            cycleType: cycleType,
            schedule: schedule,
            timesOfDay: timesOfDay,
            daysOfMonth: daysOfMonth,
            existingAlarms: existingAlarms
        )
    }
}

struct AlarmListValidatorConflictTests {

    // MARK: - Same-Time Conflict Warning

    @Test func sameTimeConflictOverlappingWeeklyDays() {
        let existing = makeAlarm(
            title: "Morning Jog",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 7, minute: 0)],
            schedule: .weekly(daysOfWeek: [2, 4, 6], interval: 1)
        )
        let result = validate(
            title: "Take Vitamins",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [4, 5], interval: 1),
            timesOfDay: [TimeOfDay(hour: 7, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(hasConflict)
    }

    @Test func noConflictWeeklyNonOverlappingDays() {
        let existing = makeAlarm(
            title: "Morning Jog",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 7, minute: 0)],
            schedule: .weekly(daysOfWeek: [2, 4], interval: 1)
        )
        let result = validate(
            title: "Take Vitamins",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [3, 6], interval: 1),
            timesOfDay: [TimeOfDay(hour: 7, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(!hasConflict)
    }

    @Test func noConflictDifferentTimeSameDays() {
        let existing = makeAlarm(
            title: "Morning Jog",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 7, minute: 0)],
            schedule: .weekly(daysOfWeek: [2, 4], interval: 1)
        )
        let result = validate(
            title: "Take Vitamins",
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2, 4], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(!hasConflict)
    }

    @Test func sameTimeConflictMonthlyOverlappingDays() {
        let existing = makeAlarm(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .monthlyDate(daysOfMonth: [1, 15], interval: 1)
        )
        let result = validate(
            title: "Pay Bills",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [15, 28], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(hasConflict)
    }

    @Test func sameTimeConflictAnnualSameDate() {
        let existing = makeAlarm(
            title: "Birthday Reminder",
            cycleType: .annual,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1)
        )
        let result = validate(
            title: "Anniversary",
            cycleType: .annual,
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(hasConflict)
    }

    @Test func noConflictAnnualDifferentDate() {
        let existing = makeAlarm(
            title: "Birthday Reminder",
            cycleType: .annual,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1)
        )
        let result = validate(
            title: "Anniversary",
            cycleType: .annual,
            schedule: .annual(month: 6, dayOfMonth: 20, interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(!hasConflict)
    }

    @Test func noConflictDifferentScheduleTypes() {
        let existing = makeAlarm(
            title: "Weekly Task",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "Monthly Task",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [2], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(!hasConflict)
    }

    // MARK: - Monthly Day-31 Warning

    @Test func monthlyDay31WarningWhenDayAbove28() {
        let result = validate(
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [15, 31], interval: 1),
            daysOfMonth: [15, 31]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(hasDay31)
    }

    @Test func monthlyDay29WarningTriggered() {
        let result = validate(
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [29], interval: 1),
            daysOfMonth: [29]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(hasDay31)
    }

    @Test func monthlyDay30WarningTriggered() {
        let result = validate(
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [30], interval: 1),
            daysOfMonth: [30]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(hasDay31)
    }

    @Test func noMonthlyDay31WarningWhenAllDaysBelow29() {
        let result = validate(
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [1, 15, 28], interval: 1),
            daysOfMonth: [1, 15, 28]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(!hasDay31)
    }

    @Test func noMonthlyDay31WarningForWeeklySchedule() {
        let result = validate(
            cycleType: .weekly,
            schedule: .weekly(daysOfWeek: [2], interval: 1),
            daysOfMonth: [31]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(!hasDay31)
    }

    @Test func monthlyRelativeAlsoChecksDay31() {
        let result = validate(
            cycleType: .monthlyRelative,
            schedule: .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1),
            daysOfMonth: [29]
        )
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(hasDay31)
    }

    // MARK: - Combined Validation

    @Test func emptyTitleShortCircuitsNoWarnings() {
        let existing = makeAlarm(
            title: "",
            cycleType: .monthlyDate,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1)
        )
        let result = validate(
            title: "",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            daysOfMonth: [31],
            existingAlarms: [existing]
        )
        #expect(!result.isValid)
        #expect(result.errors.contains(.emptyTitle))
        #expect(result.warnings.isEmpty)
    }

    @Test func multipleWarningsCanCoexist() {
        let existing = makeAlarm(
            title: "Monthly Reminder",
            cycleType: .monthlyDate,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1)
        )
        let result = validate(
            title: "Monthly Reminder",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(daysOfMonth: [31], interval: 1),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            daysOfMonth: [31],
            existingAlarms: [existing]
        )
        #expect(result.isValid)
        let hasDuplicate = result.warnings.contains(where: {
            if case .duplicateAlarm = $0 { return true }
            return false
        })
        let hasDay31 = result.warnings.contains(.monthlyDay31)
        #expect(hasDuplicate)
        #expect(hasDay31)
        #expect(result.warnings.count >= 2)
    }

    // MARK: - ValidationResult

    @Test func isValidTrueWhenNoErrors() {
        let result = AlarmValidator.ValidationResult(errors: [], warnings: [.monthlyDay31])
        #expect(result.isValid)
    }

    @Test func isValidFalseWhenErrorsPresent() {
        let result = AlarmValidator.ValidationResult(errors: [.emptyTitle], warnings: [])
        #expect(!result.isValid)
    }

    // MARK: - Warning Display Messages

    @Test func duplicateAlarmDisplayMessageContainsTitle() {
        let warning = AlarmValidator.ValidationWarning.duplicateAlarm(existingTitle: "Pay Rent")
        #expect(warning.displayMessage.contains("Pay Rent"))
    }

    @Test func sameTimeConflictDisplayMessageContainsTitleAndTime() {
        let warning = AlarmValidator.ValidationWarning.sameTimeConflict(
            existingTitle: "Morning Jog",
            time: "8:00 AM"
        )
        #expect(warning.displayMessage.contains("Morning Jog"))
        #expect(warning.displayMessage.contains("8:00 AM"))
    }

    @Test func monthlyDay31DisplayMessage() {
        let warning = AlarmValidator.ValidationWarning.monthlyDay31
        #expect(warning.displayMessage == "Some months have fewer days. The alarm won't fire on days that don't exist in a given month.")
    }

    // MARK: - One-Time No Overlap

    @Test func oneTimeNeverOverlapsWithRecurring() {
        let existing = makeAlarm(
            title: "Weekly Task",
            cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let result = validate(
            title: "One-Time Task",
            cycleType: .oneTime,
            schedule: .oneTime(fireDate: Date()),
            timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
            existingAlarms: [existing]
        )
        let hasConflict = result.warnings.contains(where: {
            if case .sameTimeConflict = $0 { return true }
            return false
        })
        #expect(!hasConflict)
    }

    // MARK: - Schedule Codable Round-Trip

    @Test func oneTimeScheduleCodableRoundTrip() throws {
        let fireDate = Date(timeIntervalSince1970: 1_800_000_000)
        let original = Schedule.oneTime(fireDate: fireDate)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Schedule.self, from: data)
        #expect(original == decoded)
    }

    // MARK: - Edge Cases

    @Test func validationWithNoExistingAlarms() {
        let result = validate(
            title: "New Alarm",
            existingAlarms: []
        )
        #expect(result.isValid)
        #expect(result.warnings.isEmpty)
    }

    @Test func validationWithEmptyTimesOfDay() {
        let result = validate(
            title: "New Alarm",
            timesOfDay: []
        )
        #expect(result.isValid)
    }

    @Test func titleWithOnlyControlCharactersReturnsEmptyTitleError() {
        let result = validate(title: "\u{07}\u{08}")
        #expect(!result.isValid)
        #expect(result.errors.contains(.emptyTitle))
    }

    @Test func duplicateAlarmDisplayMessageFormat() {
        let warning = AlarmValidator.ValidationWarning.duplicateAlarm(existingTitle: "Test")
        #expect(warning.displayMessage == "\"Test\" has the same name, schedule, and time.")
    }

    @Test func sameTimeConflictDisplayMessageFormat() {
        let warning = AlarmValidator.ValidationWarning.sameTimeConflict(
            existingTitle: "Test",
            time: "9:00 AM"
        )
        #expect(warning.displayMessage == "\"Test\" also fires at 9:00 AM on overlapping days.")
    }
}
