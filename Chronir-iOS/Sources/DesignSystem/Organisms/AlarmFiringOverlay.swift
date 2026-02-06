import SwiftUI

struct AlarmFiringOverlay: View {
    let alarm: Alarm
    let onDismiss: () -> Void
    let onSnooze: (SnoozeOptionBar.SnoozeInterval) -> Void

    var body: some View {
        VStack(spacing: SpacingTokens.xxxl) {
            Spacer()

            ChronirText(alarm.title, style: .headlineLarge)

            ChronirText(
                alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                style: .displayLarge
            )

            ChronirBadge(cycleType: alarm.cycleType)

            Spacer()

            SnoozeOptionBar(onSnooze: onSnooze)

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
        onSnooze: { _ in  }
    )
}
