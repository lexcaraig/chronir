import SwiftUI

struct AlarmListSection: View {
    let title: String
    let alarms: [Alarm]
    @Binding var enabledStates: [UUID: Bool]
    var onAlarmSelected: (UUID) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.xs) {
                ChronirText(
                    title.uppercased(),
                    style: .labelLarge,
                    color: ColorTokens.textSecondary
                )
                ChronirBadge("\(alarms.count)", color: ColorTokens.backgroundTertiary)
            }
            .padding(.horizontal, SpacingTokens.md)

            ForEach(alarms) { alarm in
                AlarmCard(
                    alarm: alarm,
                    visualState: visualState(for: alarm),
                    isEnabled: binding(for: alarm)
                )
                .contentShape(Rectangle())
                .onTapGesture { onAlarmSelected(alarm.id) }
                .padding(.horizontal, SpacingTokens.md)
            }
        }
    }

    private func visualState(for alarm: Alarm) -> AlarmVisualState {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        if !isEnabled { return .inactive }
        if alarm.snoozeCount > 0 { return .snoozed }
        if alarm.nextFireDate < Date() { return .overdue }
        return .active
    }

    private func binding(for alarm: Alarm) -> Binding<Bool> {
        Binding(
            get: { enabledStates[alarm.id] ?? alarm.isEnabled },
            set: { enabledStates[alarm.id] = $0 }
        )
    }
}

#Preview {
    @Previewable @State var enabledStates: [UUID: Bool] = [:]
    let alarms = [
        Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            nextFireDate: Date().addingTimeInterval(3600),
            persistenceLevel: .full
        ),
        Alarm(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(dayOfMonth: 1, interval: 1),
            nextFireDate: Date().addingTimeInterval(-3600)
        ),
        Alarm(
            title: "Annual Checkup",
            cycleType: .annual,
            schedule: .annual(month: 3, dayOfMonth: 15, interval: 1),
            nextFireDate: Date().addingTimeInterval(86400)
        )
    ]
    NavigationStack {
        ScrollView {
            AlarmListSection(
                title: "Upcoming",
                alarms: alarms,
                enabledStates: $enabledStates,
            )
        }
    }
    .background(ColorTokens.backgroundPrimary)
}
