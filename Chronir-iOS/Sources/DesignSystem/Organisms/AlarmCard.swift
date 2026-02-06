import SwiftUI

enum AlarmVisualState {
    case active
    case inactive
    case snoozed
    case overdue

    var accentColor: Color? {
        switch self {
        case .active: return nil
        case .inactive: return nil
        case .snoozed: return ColorTokens.warning
        case .overdue: return ColorTokens.error
        }
    }

    var statusBadge: (text: String, color: Color)? {
        switch self {
        case .active: return nil
        case .inactive: return nil
        case .snoozed: return ("Snoozed", ColorTokens.warning)
        case .overdue: return ("Missed", ColorTokens.error)
        }
    }
}

struct AlarmCard: View {
    let alarm: Alarm
    let visualState: AlarmVisualState
    @Binding var isEnabled: Bool
    var onDelete: (() -> Void)?

    private var textOpacity: Double {
        visualState == .inactive ? 0.5 : 1.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack {
                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    ChronirText(
                        alarm.title,
                        style: .titleMedium,
                        color: visualState == .inactive ? ColorTokens.textDisabled : ColorTokens.textPrimary
                    )
                    HStack(spacing: SpacingTokens.xs) {
                        ChronirBadge(cycleType: alarm.cycleType)
                        if let badge = visualState.statusBadge {
                            ChronirBadge(badge.text, color: badge.color)
                        }
                    }
                }
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .tint(ColorTokens.primary)
                    .labelsHidden()
            }

            HStack {
                if visualState != .inactive {
                    AlarmTimeDisplay(
                        time: alarm.scheduledTime,
                        countdownText: visualState == .active ? "Alarm in 6h 32m" : nil
                    )
                } else {
                    ChronirText(
                        alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                        style: .headlineTime,
                        color: ColorTokens.textDisabled
                    )
                }
                Spacer()
                if alarm.isPersistent {
                    ChronirBadge("Persistent", color: ColorTokens.warning)
                }
            }
        }
        .padding(SpacingTokens.lg)
        .background(ColorTokens.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
        .overlay(
            RoundedRectangle(cornerRadius: RadiusTokens.md)
                .stroke(visualState.accentColor ?? .clear, lineWidth: visualState.accentColor != nil ? 2 : 0)
        )
        .opacity(textOpacity)
    }
}

// MARK: - Preview Helpers

private extension AlarmCard {
    static var sampleAlarm: Alarm {
        Alarm(
            title: "Morning Workout",
            cycleType: .weekly,
            persistenceLevel: .full
        )
    }

    static var sampleAlarmMonthly: Alarm {
        Alarm(
            title: "Pay Rent",
            cycleType: .monthlyDate,
            schedule: .monthlyDate(dayOfMonth: 1, interval: 1)
        )
    }
}

#Preview("Active") {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: AlarmCard.sampleAlarm,
        visualState: .active,
        isEnabled: $isEnabled
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Inactive") {
    @Previewable @State var isEnabled = false
    AlarmCard(
        alarm: AlarmCard.sampleAlarmMonthly,
        visualState: .inactive,
        isEnabled: $isEnabled
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Snoozed") {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: AlarmCard.sampleAlarm,
        visualState: .snoozed,
        isEnabled: $isEnabled
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Overdue") {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: AlarmCard.sampleAlarmMonthly,
        visualState: .overdue,
        isEnabled: $isEnabled
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark — All States") {
    @Previewable @State var enabled1 = true
    @Previewable @State var enabled2 = false
    @Previewable @State var enabled3 = true
    @Previewable @State var enabled4 = true
    DarkPreview {
        VStack(spacing: SpacingTokens.md) {
            AlarmCard(alarm: AlarmCard.sampleAlarm, visualState: .active, isEnabled: $enabled1)
            AlarmCard(alarm: AlarmCard.sampleAlarmMonthly, visualState: .inactive, isEnabled: $enabled2)
            AlarmCard(alarm: AlarmCard.sampleAlarm, visualState: .snoozed, isEnabled: $enabled3)
            AlarmCard(alarm: AlarmCard.sampleAlarmMonthly, visualState: .overdue, isEnabled: $enabled4)
        }
        .padding()
    }
}
