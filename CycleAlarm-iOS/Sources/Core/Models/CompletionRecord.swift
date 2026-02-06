import Foundation

enum CompletionAction: String, Codable, CaseIterable {
    case dismissed
    case snoozed
    case completed
}

struct CompletionRecord: Identifiable, Codable, Hashable {
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
