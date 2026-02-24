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
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "alarm.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.state.alarmTitle)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.state.fireDate, style: .timer)
                            .font(.title2.monospacedDigit())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                        Text(context.attributes.cycleType)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.white)
            } compactTrailing: {
                Text(context.state.fireDate, style: .timer)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .frame(minWidth: 40)
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Lock Screen View

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<AlarmCountdownAttributes>

    var body: some View {
        HStack(spacing: WidgetTokens.spacingMD) {
            Image(systemName: "alarm.fill")
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.alarmTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(context.attributes.cycleType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(context.state.fireDate, style: .timer)
                .font(.title.monospacedDigit())
        }
        .padding(WidgetTokens.spacingLG)
    }
}
