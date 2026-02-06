import SwiftUI

struct AlarmFiringOverlay: View {
    let alarm: Alarm
    let onDismiss: () -> Void
    let onSnooze: (Int) -> Void

    var body: some View {
        VStack(spacing: SpacingTokens.xxxl) {
            Spacer()

            ChronirText(alarm.title, font: TypographyTokens.headlineLarge)

            ChronirText(
                alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                font: TypographyTokens.displayLarge
            )

            ChronirBadge(alarm.cycleType.displayName)

            Spacer()

            HStack(spacing: SpacingTokens.md) {
                SnoozeOptionButton(minutes: 5) { onSnooze(5) }
                SnoozeOptionButton(minutes: 10) { onSnooze(10) }
                SnoozeOptionButton(minutes: 15) { onSnooze(15) }
            }

            ChronirButton("Dismiss", style: .primary, action: onDismiss)
                .padding(.horizontal, SpacingTokens.xxxl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview {
    AlarmFiringOverlay(
        alarm: Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            scheduledTime: Date(),
            nextFireDate: Date(),
            isPersistent: true
        ),
        onDismiss: {},
        onSnooze: { _ in }
    )
}
