import Foundation

/// Lightweight alarm data for cross-process widget serialization.
/// Deliberately separate from AlarmSummary — this is Codable for JSON transport
/// between the main app and the widget extension via App Groups.
struct WidgetAlarmData: Codable, Sendable {
    let id: UUID
    let title: String
    let nextFireDate: Date
    let scheduleDisplayName: String
    let cycleType: String
    let categoryName: String?
    let categoryIconName: String?
    let colorTag: String?
}

struct WidgetDataPayload: Codable, Sendable {
    let alarms: [WidgetAlarmData]
    let lastUpdated: Date
}
