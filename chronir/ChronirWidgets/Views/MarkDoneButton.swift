import AppIntents
import SwiftUI
import WidgetKit

/// Interactive widget button that completes the alarm's upcoming occurrence in place.
struct MarkDoneButton: View {
    let alarm: WidgetAlarmData

    var body: some View {
        Button(intent: CompleteAlarmIntent(alarm: AlarmEntity(alarm), expectedFireDate: alarm.nextFireDate)) {
            Image(systemName: "checkmark.circle")
                .font(.title3)
                .foregroundStyle(WidgetTokens.categoryColor(for: alarm.categoryName))
                .frame(minWidth: 28, minHeight: 28) // token-exempt: widget tap target; rows too short for 44pt
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mark \(alarm.title) as done")
    }
}
