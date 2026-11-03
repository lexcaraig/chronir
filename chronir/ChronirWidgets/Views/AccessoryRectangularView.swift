import SwiftUI
import WidgetKit

/// Lock screen rectangular widget: the next alarm (what + when), plus the one after it.
struct AccessoryRectangularView: View {
    let alarms: [WidgetAlarmData]

    var body: some View {
        if let next = alarms.first {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: WidgetTokens.spacingXS) {
                    if let iconName = next.categoryIconName {
                        Image(systemName: iconName)
                            .font(.caption2)
                            .widgetAccentable()
                            .accessibilityHidden(true)
                    }
                    Text(next.title)
                        .font(.headline)
                        .lineLimit(1)
                        .widgetAccentable()
                }
                Text(next.nextFireDate, style: .relative)
                    .font(.caption)
                    .lineLimit(1)
                if alarms.count > 1 {
                    let following = alarms[1]
                    let day = following.nextFireDate.formatted(.dateTime.month(.abbreviated).day())
                    ViewThatFits(in: .horizontal) {
                        Text("\(following.title) \u{00B7} \(day)")
                        Text(following.title)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading) {
                Label("No alarms", systemImage: "bell.slash")
                    .font(.headline)
                Text("Add alarms in Chronir")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Rectangular", as: .accessoryRectangular) {
    AlarmListWidget()
} timeline: {
    AlarmListEntry(date: .now, alarms: [.preview, .preview])
}
