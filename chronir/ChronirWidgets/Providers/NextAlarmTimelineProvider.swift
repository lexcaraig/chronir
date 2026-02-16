import WidgetKit
import SwiftUI

struct NextAlarmEntry: TimelineEntry {
    let date: Date
    let alarm: WidgetAlarmData?
}

struct NextAlarmTimelineProvider: TimelineProvider {
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

    func getSnapshot(in context: Context, completion: @escaping (NextAlarmEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            let alarm = WidgetDataReader.nextAlarm()
            completion(NextAlarmEntry(date: Date(), alarm: alarm))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextAlarmEntry>) -> Void) {
        let alarm = WidgetDataReader.nextAlarm()
        let entry = NextAlarmEntry(date: Date(), alarm: alarm)

        // Refresh at the alarm's fire time (if within 24h), or every 15 minutes
        let refreshDate: Date
        if let fireDate = alarm?.nextFireDate,
           fireDate.timeIntervalSinceNow < 86400 && fireDate.timeIntervalSinceNow > 0 {
            refreshDate = fireDate
        } else {
            refreshDate = Date().addingTimeInterval(900)
        }

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}
