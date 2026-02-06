import SwiftUI

struct AlarmListSection: View {
    let title: String
    let alarms: [Alarm]

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            CycleText(title, font: TypographyTokens.titleSmall, color: ColorTokens.textSecondary)
                .padding(.horizontal, SpacingTokens.lg)

            ForEach(alarms) { alarm in
                // TODO: Implement in Sprint 1 - wire up toggle binding
                Text(alarm.title)
                    .foregroundStyle(ColorTokens.textPrimary)
                    .padding(.horizontal, SpacingTokens.lg)
            }
        }
    }
}

#Preview {
    AlarmListSection(
        title: "Active Alarms",
        alarms: [
            Alarm(title: "Workout", cycleType: .weekly, scheduledTime: Date(), nextFireDate: Date()),
            Alarm(title: "Bills", cycleType: .monthly, scheduledTime: Date(), nextFireDate: Date())
        ]
    )
    .padding(.vertical)
    .background(ColorTokens.backgroundPrimary)
}
