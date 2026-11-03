import SwiftUI
import WidgetKit

/// Home screen medium widget: the next two alarms with countdowns and Mark Done buttons.
struct SystemMediumView: View {
    let alarms: [WidgetAlarmData]
    @Environment(\.widgetRenderingMode) private var renderingMode

    /// Two rows leave room for 44pt Mark Done targets inside the system content margins.
    private let visibleCount = 2

    var body: some View {
        if alarms.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: WidgetTokens.spacingSM) {
                    Image(systemName: "bell.slash")
                        .font(.title)
                        .foregroundStyle(WidgetTokens.textSecondary)
                        .accessibilityHidden(true)
                    Text("No upcoming alarms")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(WidgetTokens.textSecondary)
                    Text("Add alarms in Chronir")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(WidgetTokens.textSecondary)
                }
                Spacer()
            }
        } else {
            VStack(alignment: .leading, spacing: WidgetTokens.spacingXS) {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(
                            renderingMode == .fullColor ? AnyShapeStyle(WidgetTokens.accent) : AnyShapeStyle(.primary)
                        )
                        .widgetAccentable()
                        .accessibilityHidden(true)
                    Text("Upcoming Alarms")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(WidgetTokens.textSecondary)
                    Spacer()
                    if alarms.count > visibleCount {
                        Text("+\(alarms.count - visibleCount) more")
                            .font(.caption2)
                            .foregroundStyle(WidgetTokens.textSecondary)
                    }
                }

                ForEach(alarms.prefix(visibleCount), id: \.id) { alarm in
                    HStack(spacing: WidgetTokens.spacingMD) {
                        if let url = URL(string: "chronir://alarm/\(alarm.id.uuidString)") {
                            Link(destination: url) {
                                alarmRow(alarm)
                            }
                        }
                        MarkDoneButton(alarm: alarm)
                    }
                }
            }
        }
    }

    private func alarmRow(_ alarm: WidgetAlarmData) -> some View {
        HStack(spacing: WidgetTokens.spacingSM) {
            categoryMarker(alarm)

            VStack(alignment: .leading, spacing: 0) {
                Text(alarm.title)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(WidgetTokens.textPrimary)
                    .lineLimit(1)
                Text(alarm.nextFireDate, style: .relative)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(WidgetTokens.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    /// Color dot in full color; in tinted/clear modes hue is lost, so show the category symbol instead.
    @ViewBuilder
    private func categoryMarker(_ alarm: WidgetAlarmData) -> some View {
        if renderingMode == .fullColor {
            Circle()
                .fill(WidgetTokens.categoryColor(for: alarm.categoryName))
                .frame(width: WidgetTokens.spacingSM, height: WidgetTokens.spacingSM)
                .accessibilityHidden(true)
        } else {
            Image(systemName: alarm.categoryIconName ?? "bell.fill")
                .font(.caption2)
                .widgetAccentable()
                .accessibilityHidden(true)
        }
    }
}

#Preview("Medium", as: .systemMedium) {
    AlarmListWidget()
} timeline: {
    AlarmListEntry(date: .now, alarms: [.preview, .preview, .preview])
}

#Preview("Medium, Empty", as: .systemMedium) {
    AlarmListWidget()
} timeline: {
    AlarmListEntry(date: .now, alarms: [])
}
