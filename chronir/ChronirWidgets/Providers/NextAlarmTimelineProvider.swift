import WidgetKit
import SwiftUI

struct NextAlarmEntry: TimelineEntry {
    let date: Date
    let alarm: WidgetAlarmData?
    var pinnedMissing = false
    var relevance: TimelineEntryRelevance?
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
        let now = Date()

        // Refresh at the alarm's fire time (if within 24h), or every 15 minutes
        let refreshDate: Date
        if let fireDate = alarm?.nextFireDate,
           fireDate.timeIntervalSinceNow < 86400 && fireDate.timeIntervalSinceNow > 0 {
            refreshDate = fireDate
        } else {
            refreshDate = now.addingTimeInterval(900)
        }

        var entryDates = WidgetRelevance.entryDates(now: now, fireDate: alarm?.nextFireDate, until: refreshDate)
        // The circular gauge prints a remaining value ("5h", "42m"); give it an entry at every change
        // so it never sits on a stale reading between reloads.
        if context.family == .accessoryCircular, let fireDate = alarm?.nextFireDate, fireDate != .distantFuture {
            entryDates += AccessoryCircularView.valueChangeDates(fireDate: fireDate, after: now, before: refreshDate)
        }
        let entries = Set(entryDates).sorted()
            .map { date in
                NextAlarmEntry(
                    date: date,
                    alarm: alarm,
                    pinnedMissing: resolved.pinnedMissing,
                    relevance: WidgetRelevance.relevance(at: date, fireDate: alarm?.nextFireDate)
                )
            }
        return Timeline(entries: entries, policy: .after(refreshDate))
    }
}
