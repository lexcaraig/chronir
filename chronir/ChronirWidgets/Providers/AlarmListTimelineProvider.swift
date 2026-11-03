import WidgetKit
import SwiftUI

struct AlarmListEntry: TimelineEntry {
    let date: Date
    let alarms: [WidgetAlarmData]
    var relevance: TimelineEntryRelevance?
}

struct AlarmListTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlarmListEntry {
        AlarmListEntry(
            date: Date(),
            alarms: [
                WidgetAlarmData(
                    id: UUID(), title: "Rent Due",
                    nextFireDate: Date().addingTimeInterval(86400 * 3),
                    scheduleDisplayName: "Monthly on 1st",
                    cycleType: "monthlyDate", categoryName: "finance",
                    categoryIconName: "dollarsign.circle.fill", colorTag: nil
                ),
                WidgetAlarmData(
                    id: UUID(), title: "Car Service",
                    nextFireDate: Date().addingTimeInterval(86400 * 14),
                    scheduleDisplayName: "Every 6 months",
                    cycleType: "annual", categoryName: "vehicle",
                    categoryIconName: "car.fill", colorTag: nil
                ),
                WidgetAlarmData(
                    id: UUID(), title: "Dentist",
                    nextFireDate: Date().addingTimeInterval(86400 * 30),
                    scheduleDisplayName: "Every 6 months",
                    cycleType: "annual", categoryName: "health",
                    categoryIconName: "heart.fill", colorTag: nil
                )
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmListEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            let alarms = Array(WidgetDataReader.loadAlarms().prefix(5))
            completion(AlarmListEntry(date: Date(), alarms: alarms))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmListEntry>) -> Void) {
        let alarms = Array(WidgetDataReader.loadAlarms().prefix(5))
        let now = Date()
        let soonestFire = alarms.first?.nextFireDate

        // Refresh at the soonest alarm's fire time, or every 15 minutes
        let refreshDate: Date
        if let soonest = soonestFire,
           soonest.timeIntervalSinceNow < 86400 && soonest.timeIntervalSinceNow > 0 {
            refreshDate = soonest
        } else {
            refreshDate = now.addingTimeInterval(900)
        }

        let entries = WidgetRelevance.entryDates(now: now, fireDate: soonestFire, until: refreshDate)
            .map { date in
                AlarmListEntry(
                    date: date,
                    alarms: alarms,
                    relevance: WidgetRelevance.relevance(at: date, fireDate: soonestFire)
                )
            }
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}
