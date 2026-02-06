import SwiftUI
import WidgetKit

// TODO: Move to a separate Widget Extension target when creating the Xcode project

struct NextAlarmEntry: TimelineEntry {
    let date: Date
    let alarmTitle: String
    let nextFireDate: Date?
    let cycleType: CycleType?
}

struct NextAlarmWidgetEntryView: View {
    let entry: NextAlarmEntry

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            HStack {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(ColorTokens.primary)
                Text("Next Alarm")
                    .font(TypographyTokens.labelSmall)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            if let fireDate = entry.nextFireDate {
                Text(entry.alarmTitle)
                    .font(TypographyTokens.titleSmall)
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(fireDate, style: .relative)
                    .font(TypographyTokens.bodySmall)
                    .foregroundStyle(ColorTokens.textSecondary)
            } else {
                Text("No upcoming alarms")
                    .font(TypographyTokens.bodySmall)
                    .foregroundStyle(ColorTokens.textTertiary)
            }
        }
        .padding(SpacingTokens.md)
    }
}

struct NextAlarmTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextAlarmEntry {
        NextAlarmEntry(date: Date(), alarmTitle: "Alarm", nextFireDate: Date().addingTimeInterval(3600), cycleType: .weekly)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextAlarmEntry) -> Void) {
        let entry = NextAlarmEntry(date: Date(), alarmTitle: "Morning Workout", nextFireDate: Date().addingTimeInterval(3600), cycleType: .weekly)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextAlarmEntry>) -> Void) {
        // TODO: Implement in Sprint 3 - fetch from shared app group container
        let entry = NextAlarmEntry(date: Date(), alarmTitle: "No alarms", nextFireDate: nil, cycleType: nil)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}
