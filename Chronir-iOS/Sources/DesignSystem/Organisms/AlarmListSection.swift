import SwiftUI

struct AlarmListSection: View {
    let title: String
    let alarms: [Alarm]
    @Binding var enabledStates: [UUID: Bool]
    var onDelete: ((Alarm) -> Void)? = nil

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
            .padding(.horizontal, SpacingTokens.lg)

            ForEach(alarms) { alarm in
                AlarmCard(
                    alarm: alarm,
                    visualState: visualState(for: alarm),
                    isEnabled: binding(for: alarm),
                    onDelete: onDelete.map { delete in { delete(alarm) } }
                )
                .padding(.horizontal, SpacingTokens.lg)
            }
        }
    }

    private func visualState(for alarm: Alarm) -> AlarmVisualState {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        if !isEnabled { return .inactive }
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
        Alarm(title: "Morning Workout", cycleType: .weekly, scheduledTime: Date(), nextFireDate: Date().addingTimeInterval(3600), isPersistent: true),
        Alarm(title: "Pay Rent", cycleType: .monthly, scheduledTime: Date(), nextFireDate: Date().addingTimeInterval(-3600)),
        Alarm(title: "Annual Checkup", cycleType: .yearly, scheduledTime: Date(), nextFireDate: Date().addingTimeInterval(86400))
    ]
    ScrollView {
        AlarmListSection(
            title: "Upcoming",
            alarms: alarms,
            enabledStates: $enabledStates,
            onDelete: { _ in }
        )
    }
    .background(ColorTokens.backgroundPrimary)
}
