import Foundation
import SwiftUI

// TODO: Move CountdownLiveActivityView to a Widget Extension target
// TODO: Replace with AlarmKit Live Activity when Xcode 18/iOS 26 is available

#if canImport(ActivityKit)
import ActivityKit

/// Attributes for the countdown Live Activity.
/// Used by the main app to start/update activities via ActivityKit.
struct AlarmCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var alarmTitle: String
        var fireDate: Date
    }

    var alarmID: String
    var cycleType: String
}
#endif

// MARK: - Live Activity View (Widget Extension only)

// ActivityViewContext requires a WidgetKit Widget Extension target.
// The view below will be enabled when the Widget Extension is created.
// Until then, it is excluded from compilation to avoid build errors
// in the main app target.

#if CHRONIR_WIDGET_EXTENSION
import WidgetKit

struct CountdownLiveActivityView: View {
    let context: ActivityViewContext<AlarmCountdownAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                Text(context.state.alarmTitle)
                    .font(TypographyTokens.titleSmall)
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(context.attributes.cycleType)
                    .font(TypographyTokens.labelSmall)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            Spacer()

            Text(context.state.fireDate, style: .timer)
                .font(TypographyTokens.headlineMedium)
                .foregroundStyle(ColorTokens.primary)
                .monospacedDigit()
        }
        .padding(SpacingTokens.lg)
    }
}
#endif
