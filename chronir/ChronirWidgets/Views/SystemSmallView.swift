import SwiftUI
import WidgetKit

/// Home screen small widget: next alarm with category color accent
struct SystemSmallView: View {
    let alarm: WidgetAlarmData?
    var pinnedMissing = false
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if let alarm {
            VStack(alignment: .leading, spacing: WidgetTokens.spacingSM) {
                HStack {
                    Image(systemName: alarm.categoryIconName ?? "bell.fill")
                        .font(.caption)
                        .foregroundStyle(
                            renderingMode == .fullColor
                                ? AnyShapeStyle(WidgetTokens.categoryColor(for: alarm.categoryName))
                                : AnyShapeStyle(.primary)
                        )
                        .widgetAccentable()
                        .accessibilityHidden(true)
                    Spacer()
                    cycleBadge(alarm.cycleType)
                }

                Text(alarm.title)
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(2)
                    .foregroundStyle(WidgetTokens.textPrimary)

                if pinnedMissing {
                    Text("Pinned alarm removed")
                        .font(.caption2)
                        .foregroundStyle(WidgetTokens.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: WidgetTokens.spacingXS) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(alarm.nextFireDate, style: .relative)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(WidgetTokens.textSecondary)

                        Text(alarm.scheduleDisplayName)
                            .font(.caption2)
                            .foregroundStyle(WidgetTokens.textSecondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    MarkDoneButton(alarm: alarm)
                        // Pull the 44pt target into the corner so it doesn't eat the text column.
                        .padding(.trailing, -WidgetTokens.spacingSM)
                        .padding(.bottom, -WidgetTokens.spacingSM)
                }
            }
            .widgetURL(URL(string: "chronir://alarm/\(alarm.id.uuidString)"))
        } else {
            VStack(spacing: WidgetTokens.spacingSM) {
                Image(systemName: "bell.slash")
                    .font(.title2)
                    .foregroundStyle(WidgetTokens.textSecondary)
                    .accessibilityHidden(true)
                Text("No alarms")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(WidgetTokens.textSecondary)
            }
        }
    }

    private func cycleBadge(_ cycleType: String) -> some View {
        Text(WidgetAlarmData.cycleDisplayName(cycleType))
            .font(.caption2.weight(.medium))
            .padding(.horizontal, WidgetTokens.spacingSM)
            .padding(.vertical, WidgetTokens.spacingXS / 2)
            .background(.quaternary)
            .clipShape(Capsule())
    }
}

#Preview("Light", as: .systemSmall) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(date: .now, alarm: .preview)
}

#Preview("Empty", as: .systemSmall) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(date: .now, alarm: nil)
}
