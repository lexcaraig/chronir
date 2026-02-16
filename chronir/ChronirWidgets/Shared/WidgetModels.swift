import Foundation

/// Mirror of the main app's WidgetAlarmData for cross-process JSON transport.
/// Must stay in sync with chronir/Core/Models/WidgetAlarmData.swift.
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
