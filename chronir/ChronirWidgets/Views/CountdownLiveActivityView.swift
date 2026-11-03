import SwiftUI
import WidgetKit
import ActivityKit

/// Duplicate of AlarmCountdownAttributes for the widget extension target.
/// The main app has its own copy in Widgets/CountdownLiveActivity.swift.
struct AlarmCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var alarmTitle: String
        var fireDate: Date
    }

    var alarmID: String
    var cycleType: String
}

// MARK: - Live Activity Widget

struct CountdownLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmCountdownAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .widgetURL(context.alarmURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "alarm.fill")
                        .font(.title2)
                        .foregroundStyle(WidgetTokens.accent)
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.alarmTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    LiveCountdownText(context: context)
                        .font(.title3.monospacedDigit())
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 80, alignment: .trailing) // token-exempt: Dynamic Island region width
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(WidgetAlarmData.cycleDisplayName(context.attributes.cycleType))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Label("Open", systemImage: "chevron.right")
                            .labelStyle(.titleAndIcon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(WidgetTokens.accent)
                    .accessibilityLabel(context.state.alarmTitle)
            } compactTrailing: {
                LiveCountdownText(context: context)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 52) // token-exempt: caps the timer so it can't push the leading icon
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(WidgetTokens.accent)
                    .accessibilityLabel(context.state.alarmTitle)
            }
            .widgetURL(context.alarmURL)
        }
    }
}

// MARK: - Countdown

/// Counts DOWN to the fire date and stops at 0:00. Once the activity is stale (the alarm time has passed and
/// the app hasn't run to end it — AlarmKit doesn't relaunch the app), it says so instead of counting up.
private struct LiveCountdownText: View {
    let context: ActivityViewContext<AlarmCountdownAttributes>

    var body: some View {
        let fireDate = context.state.fireDate
        let now = Date.now
        if context.isStale || fireDate <= now {
            Text("Now")
        } else {
            Text(timerInterval: now...fireDate, countsDown: true)
        }
    }
}

private extension ActivityViewContext where Attributes == AlarmCountdownAttributes {
    /// Validated deep link to the alarm (SEC-05: only a well-formed UUID becomes a link).
    var alarmURL: URL? {
        guard let id = UUID(uuidString: attributes.alarmID) else { return nil }
        return URL(string: "chronir://alarm/\(id.uuidString)")
    }
}

// MARK: - Lock Screen View

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<AlarmCountdownAttributes>

    var body: some View {
        HStack(spacing: WidgetTokens.spacingMD) {
            Image(systemName: "alarm.fill")
                .font(.title2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.alarmTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(
                    context.isStale
                        ? "Alarm time"
                        : WidgetAlarmData.cycleDisplayName(context.attributes.cycleType)
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            LiveCountdownText(context: context)
                .font(.title.monospacedDigit())
                .multilineTextAlignment(.trailing)
        }
        .padding(WidgetTokens.spacingLG)
        .accessibilityElement(children: .combine)
    }
}
