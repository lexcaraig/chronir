import SwiftUI

struct AlarmFiringOverlay: View {
    let alarm: Alarm
    let snoozeCount: Int
    let onDismiss: () -> Void
    let onSnooze: (SnoozeOptionBar.SnoozeInterval) -> Void

    init(
        alarm: Alarm,
        snoozeCount: Int = 0,
        onDismiss: @escaping () -> Void,
        onSnooze: @escaping (SnoozeOptionBar.SnoozeInterval) -> Void
    ) {
        self.alarm = alarm
        self.snoozeCount = snoozeCount
        self.onDismiss = onDismiss
        self.onSnooze = onSnooze
    }

    var body: some View {
        VStack(spacing: SpacingTokens.xxxl) {
            Spacer()

            ChronirText(alarm.title, style: .headlineLarge, color: ColorTokens.firingForeground)

            ChronirText(
                alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                style: .displayAlarm,
                color: ColorTokens.firingForeground
            )

            ChronirBadge(cycleType: alarm.cycleType)

            if let note = alarm.note, !note.isEmpty {
                ChronirText(note, style: .bodySecondary, color: ColorTokens.firingForeground.opacity(0.7))
            }

            if snoozeCount > 0 {
                ChronirText(
                    "Snoozed \(snoozeCount) time\(snoozeCount == 1 ? "" : "s")",
                    style: .bodySecondary,
                    color: ColorTokens.warning
                )
            }

            Spacer()

            SnoozeOptionBar(onSnooze: onSnooze)

            ChronirButton("Dismiss", style: .primary, action: onDismiss)
                .padding(.horizontal, SpacingTokens.xxxl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.firingBackground)
    }
}

#Preview("Default") {
    AlarmFiringOverlay(
        alarm: Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            persistenceLevel: .full
        ),
        onDismiss: {},
        onSnooze: { _ in }
    )
}

#Preview("With Note") {
    AlarmFiringOverlay(
        alarm: Alarm(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(dayOfMonth: 1, interval: 1),
            note: "Transfer to landlord account"
        ),
        onDismiss: {},
        onSnooze: { _ in }
    )
}

#Preview("Snoozed 2x") {
    AlarmFiringOverlay(
        alarm: Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            persistenceLevel: .full
        ),
        snoozeCount: 2,
        onDismiss: {},
        onSnooze: { _ in }
    )
}
