import SwiftUI

struct AlarmCard: View {
    let alarm: Alarm
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack {
                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    ChronirText(alarm.title, font: TypographyTokens.titleMedium)
                    ChronirText(
                        alarm.cycleType.displayName,
                        font: TypographyTokens.bodySmall,
                        color: ColorTokens.textSecondary
                    )
                }
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .tint(ColorTokens.primary)
                    .labelsHidden()
            }

            HStack {
                ChronirText(
                    alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                    font: TypographyTokens.displaySmall
                )
                Spacer()
                if alarm.isPersistent {
                    ChronirBadge("Persistent", color: ColorTokens.warning)
                }
            }
        }
        .padding(SpacingTokens.lg)
        .background(ColorTokens.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
    }
}

#Preview {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            scheduledTime: Date(),
            nextFireDate: Date(),
            isPersistent: true
        ),
        isEnabled: $isEnabled
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
