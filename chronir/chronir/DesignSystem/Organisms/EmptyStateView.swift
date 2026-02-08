import SwiftUI

struct EmptyStateView: View {
    let onCreateAlarm: () -> Void

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()

            Image(systemName: "bell.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(ColorTokens.textSecondary)

            ChronirText(
                "No alarms yet",
                style: .headlineTitle,
                alignment: .center
            )

            ChronirText(
                "Set recurring alarms that fire weekly, monthly, or yearly.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )

            ChronirButton("Create First Alarm", style: .primary, action: onCreateAlarm)
                .padding(.horizontal, SpacingTokens.xxl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SpacingTokens.lg)
    }
}

#Preview("Light") {
    EmptyStateView(onCreateAlarm: {})
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview {
        EmptyStateView(onCreateAlarm: {})
    }
}
