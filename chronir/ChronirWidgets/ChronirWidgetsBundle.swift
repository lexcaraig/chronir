import WidgetKit
import SwiftUI

@main
struct ChronirWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NextAlarmWidget()
        AlarmListWidget()
        CountdownLiveActivityWidget()
    }
}

// MARK: - Next Alarm Widget (single alarm — inline, circular, small)

struct NextAlarmWidget: Widget {
    let kind = "NextAlarmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextAlarmTimelineProvider()) { entry in
            NextAlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Alarm")
        .description("Shows your next upcoming alarm with a countdown.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .systemSmall])
    }
}

private struct NextAlarmWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: NextAlarmEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            AccessoryInlineView(alarm: entry.alarm)
                .containerBackground(for: .widget) {}
        case .accessoryCircular:
            AccessoryCircularView(alarm: entry.alarm)
                .containerBackground(for: .widget) {}
        case .systemSmall:
            SystemSmallView(alarm: entry.alarm)
                .containerBackground(.fill.tertiary, for: .widget)
        default:
            SystemSmallView(alarm: entry.alarm)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

// MARK: - Alarm List Widget (multi alarm — rectangular, medium)

struct AlarmListWidget: Widget {
    let kind = "AlarmListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlarmListTimelineProvider()) { entry in
            AlarmListWidgetView(entry: entry)
        }
        .configurationDisplayName("Alarm List")
        .description("Shows your upcoming alarms at a glance.")
        .supportedFamilies([.accessoryRectangular, .systemMedium])
    }
}

private struct AlarmListWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: AlarmListEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            AccessoryRectangularView(alarms: entry.alarms)
                .containerBackground(for: .widget) {}
        case .systemMedium:
            SystemMediumView(alarms: entry.alarms)
                .containerBackground(.fill.tertiary, for: .widget)
        default:
            SystemMediumView(alarms: entry.alarms)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
