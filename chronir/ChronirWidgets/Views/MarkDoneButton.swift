import AppIntents
import SwiftUI
import WidgetKit

/// Interactive widget button that completes the alarm's upcoming occurrence in place.
struct MarkDoneButton: View {
    let alarm: WidgetAlarmData
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        Button(intent: CompleteAlarmIntent(alarm: AlarmEntity(alarm), expectedFireDate: alarm.nextFireDate)) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundStyle(
                    renderingMode == .fullColor
                        ? AnyShapeStyle(WidgetTokens.categoryColor(for: alarm.categoryName))
                        : AnyShapeStyle(.primary)
                )
                .widgetAccentable()
                .frame(width: WidgetTokens.touchMinTarget, height: WidgetTokens.touchMinTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mark \(alarm.title) as done")
    }
}
