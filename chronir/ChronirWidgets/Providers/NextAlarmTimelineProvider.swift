import WidgetKit
import SwiftUI

struct NextAlarmEntry: TimelineEntry {
    let date: Date
    let alarm: WidgetAlarmData?
    var pinnedMissing = false
}

struct NextAlarmTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NextAlarmEntry {
        NextAlarmEntry(
            date: Date(),
            alarm: WidgetAlarmData(
                id: UUID(),
                title: "Morning Workout",
                nextFireDate: Date().addingTimeInterval(3600),
                scheduleDisplayName: "Every Monday",
                cycleType: "weekly",
                categoryName: "health",
                categoryIconName: "heart.fill",
                colorTag: nil
            )
        )
    }

    func snapshot(for configuration: NextAlarmConfigurationIntent, in context: Context) async -> NextAlarmEntry {
        if context.isPreview { return placeholder(in: context) }
        let resolved = WidgetDataReader.alarm(for: configuration)
        return NextAlarmEntry(date: Date(), alarm: resolved.alarm, pinnedMissing: resolved.pinnedMissing)
    }

    func timeline(
        for configuration: NextAlarmConfigurationIntent, in context: Context
    ) async -> Timeline<NextAlarmEntry> {
        let resolved = WidgetDataReader.alarm(for: configuration)
        let alarm = resolved.alarm
        let entry = NextAlarmEntry(date: Date(), alarm: alarm, pinnedMissing: resolved.pinnedMissing)

        // Refresh at the alarm's fire time (if within 24h), or every 15 minutes
        let refreshDate: Date
        if let fireDate = alarm?.nextFireDate,
           fireDate.timeIntervalSinceNow < 86400 && fireDate.timeIntervalSinceNow > 0 {
            refreshDate = fireDate
        } else {
            refreshDate = Date().addingTimeInterval(900)
        }

        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
}
