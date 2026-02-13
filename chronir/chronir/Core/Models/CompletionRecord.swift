import Foundation
import SwiftData

// MARK: - Completion Action

enum CompletionAction: String, Codable, CaseIterable {
    case dismissed
    case snoozed
    case completed
}

// MARK: - SwiftData Model

@Model
final class CompletionLog: Identifiable {
    @Attribute(.unique) var id: UUID
    var alarm: Alarm?
    var alarmID: UUID
    var scheduledDate: Date
    var completedAt: Date
    var action: CompletionAction
    var snoozeCount: Int
    var note: String?

    init(
        id: UUID = UUID(),
        alarm: Alarm? = nil,
        alarmID: UUID,
        scheduledDate: Date = Date(),
        completedAt: Date = Date(),
        action: CompletionAction,
        snoozeCount: Int = 0,
        note: String? = nil
    ) {
        self.id = id
        self.alarm = alarm
        self.alarmID = alarmID
        self.scheduledDate = scheduledDate
        self.completedAt = completedAt
        self.action = action
        self.snoozeCount = snoozeCount
        self.note = note
    }
}

// MARK: - Legacy (for migration from UserDefaults)

struct LegacyCompletionRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let alarmID: UUID
    let completedAt: Date
    let action: CompletionAction

    init(
        id: UUID = UUID(),
        alarmID: UUID,
        completedAt: Date = Date(),
        action: CompletionAction
    ) {
        self.id = id
        self.alarmID = alarmID
        self.completedAt = completedAt
        self.action = action
    }
}
