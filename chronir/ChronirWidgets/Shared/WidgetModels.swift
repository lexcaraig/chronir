import Foundation
import WidgetKit

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

// MARK: - Widget-side display helpers

extension WidgetAlarmData {
    /// "Weekly", "Monthly", ... from the raw `CycleType` string.
    static func cycleDisplayName(_ raw: String) -> String {
        switch raw {
        case "weekly": return "Weekly"
        case "monthlyDate", "monthlyRelative": return "Monthly"
        case "annual": return "Annual"
        case "customDays": return "Custom"
        case "oneTime": return "One-Time"
        default: return raw.capitalized
        }
    }

    /// Sample alarm for widget previews (new id each time so lists don't collide).
    static var preview: WidgetAlarmData {
        WidgetAlarmData(
            id: UUID(), title: "Pay Rent",
            nextFireDate: Date().addingTimeInterval(86_400 * 3),
            scheduleDisplayName: "Monthly on the 1st",
            cycleType: "monthlyDate", categoryName: "finance",
            categoryIconName: "dollarsign.circle.fill", colorTag: nil
        )
    }

    /// Approximate length of one cycle, used to scale countdown gauges to the alarm's own rhythm.
    var cycleLength: TimeInterval {
        let day: TimeInterval = 86_400
        switch cycleType {
        case "weekly": return 7 * day
        case "monthlyDate", "monthlyRelative": return 30 * day
        case "annual": return 365 * day
        default: return 30 * day
        }
    }
}

// MARK: - Smart Stack relevance

/// Long-cycle alarms are irrelevant for weeks, then critical on the day. Scores ramp up inside 24 h and 1 h
/// of the fire date so the widget rotates to the top of a Smart Stack when it matters.
enum WidgetRelevance {
    static let dayWindow: TimeInterval = 86_400
    static let hourWindow: TimeInterval = 3_600

    static func relevance(at date: Date, fireDate: Date?) -> TimelineEntryRelevance? {
        guard let fireDate, fireDate != .distantFuture else { return nil }
        let remaining = fireDate.timeIntervalSince(date)
        guard remaining > 0 else { return nil }
        if remaining <= hourWindow { return TimelineEntryRelevance(score: 100, duration: remaining) }
        if remaining <= dayWindow { return TimelineEntryRelevance(score: 50, duration: remaining - hourWindow) }
        return TimelineEntryRelevance(score: 1, duration: remaining - dayWindow)
    }

    /// Entry dates: now, plus the 24 h and 1 h thresholds that fall before the next reload.
    static func entryDates(now: Date, fireDate: Date?, until refresh: Date) -> [Date] {
        guard let fireDate else { return [now] }
        let thresholds = [fireDate.addingTimeInterval(-dayWindow), fireDate.addingTimeInterval(-hourWindow)]
        return [now] + thresholds.filter { $0 > now && $0 < refresh }
    }
}
