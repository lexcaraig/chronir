import Foundation
import ActivityKit
import SwiftUI

// TODO: Move to a separate Widget Extension target when creating the Xcode project
// TODO: Replace with AlarmKit Live Activity when Xcode 18/iOS 26 is available

struct AlarmCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var alarmTitle: String
        var fireDate: Date
    }

    var alarmID: String
    var cycleType: String
}

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
