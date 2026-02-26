import SwiftUI

enum AlarmVisualState {
    case active
    case inactive
    case snoozed
    case pending

    var accentColor: Color? {
        switch self {
        case .active: return nil
        case .inactive: return nil
        case .snoozed: return ColorTokens.warning
        case .pending: return ColorTokens.info
        }
    }

    var statusBadge: (text: String, color: Color, icon: String?)? {
        switch self {
        case .active: return nil
        case .inactive: return nil
        case .snoozed: return ("Snoozed", ColorTokens.badgeWarning, "zzz")
        case .pending: return ("Awaiting Confirmation", ColorTokens.info, "clock.badge.questionmark")
        }
    }
}

struct AlarmCard: View {
    let alarm: Alarm
    let visualState: AlarmVisualState
    @Binding var isEnabled: Bool
    var streak: Int = 0
    var isPlusUser: Bool = false

    private var textOpacity: Double {
        visualState == .inactive ? 0.5 : 1.0
    }

    private var lastCompletedText: String? {
        guard let date = alarm.lastCompletedAt else { return nil }
        let now = Date()
        let cal = Calendar.current
        let daysDiff = cal.dateComponents([.day], from: date, to: now).day ?? 0

        if cal.isDateInYesterday(date) {
            return "Last completed: Yesterday"
        } else if cal.isDateInToday(date) {
            return "Last completed: Today"
        } else if daysDiff <= 7 {
            return "Last completed: \(daysDiff) days ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = cal.isDate(date, equalTo: now, toGranularity: .year) ? "MMM d" : "MMM d, yyyy"
            return "Last completed: \(formatter.string(from: date))"
        }
    }

    private var streakBadgeColor: Color {
        if streak >= 10 { return ColorTokens.warning } // gold
        if streak >= 5 { return ColorTokens.success } // accent green
        return ColorTokens.badgeSuccess // neutral
    }

    private var streakBadgeIcon: String {
        if streak >= 10 { return "flame.fill" }
        if streak >= 5 { return "star.fill" }
        return "arrow.up.right"
    }

    private var countdownText: String? {
        guard visualState == .active || visualState == .snoozed || visualState == .pending else { return nil }
        let now = Date()
        guard alarm.nextFireDate > now else { return nil }

        let prefix = visualState == .snoozed ? "Fires in" : "Alarm in"
        let cal = Calendar.current
        let diff = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now, to: alarm.nextFireDate)
        let years = diff.year ?? 0
        let months = diff.month ?? 0
        let days = diff.day ?? 0
        let hours = diff.hour ?? 0
        let minutes = diff.minute ?? 0

        if years > 0 {
            return months > 0
                ? "\(prefix) \(years)y \(months)mo"
                : "\(prefix) \(years)y"
        } else if months > 0 {
            return days > 0
                ? "\(prefix) \(months)mo \(days)d"
                : "\(prefix) \(months)mo"
        } else if days > 0 {
            return "\(prefix) \(days)d \(hours)h"
        } else if hours > 0 {
            return "\(prefix) \(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(prefix) \(minutes)m"
        } else {
            return "\(prefix) <1m"
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack {
                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    ChronirText(
                        alarm.title,
                        style: .titleSmall,
                        color: visualState == .inactive ? ColorTokens.textDisabled : ColorTokens.textPrimary
                    )
                    HStack(spacing: SpacingTokens.xxs) {
                        ChronirBadge(schedule: alarm.schedule)
                        if let cat = alarm.alarmCategory {
                            ChronirBadge(cat.displayName, color: cat.color)
                        }
                        if let badge = visualState.statusBadge {
                            ChronirBadge(badge.text, color: badge.color, icon: badge.icon)
                        }
                    }
                }
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .tint(ColorTokens.primary)
                    .labelsHidden()
            }

            HStack(alignment: .firstTextBaseline) {
                if visualState != .inactive {
                    AlarmTimeDisplay(
                        time: alarm.nextFireDate,
                        countdownText: countdownText
                    )
                    if alarm.hasMultipleTimes {
                        ChronirBadge(
                            "+\(alarm.timesOfDay.count - 1)",
                            color: ColorTokens.backgroundTertiary
                        )
                    }
                } else {
                    ChronirText(
                        alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                        style: .headlineTime,
                        color: ColorTokens.textDisabled
                    )
                    if alarm.hasMultipleTimes {
                        ChronirBadge(
                            "+\(alarm.timesOfDay.count - 1)",
                            color: ColorTokens.backgroundTertiary
                        )
                    }
                }
                Spacer()
                if isPlusUser && streak >= 2 {
                    ChronirBadge("\(streak) streak", color: streakBadgeColor, icon: streakBadgeIcon)
                } else if !isPlusUser && streak >= 3 {
                    ChronirBadge("streak", color: ColorTokens.textDisabled)
                }
                if alarm.isPersistent {
                    ChronirBadge("Persistent", color: ColorTokens.badgeWarning, icon: "bell.badge.fill")
                }
            }
            if let text = lastCompletedText {
                ChronirText(text, style: .bodySmall, color: ColorTokens.textTertiary)
            }
        }
        .padding(SpacingTokens.cardPadding)
        .chronirGlassCard()
        .overlay(
            RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                .stroke(visualState.accentColor ?? .clear, lineWidth: visualState.accentColor != nil ? 2 : 0)
        )
        .opacity(textOpacity)
        }
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
            schedule: .monthlyDate(daysOfMonth: [1], interval: 1)
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

#Preview("Dark — All States") {
    @Previewable @State var enabled1 = true
    @Previewable @State var enabled2 = false
    @Previewable @State var enabled3 = true
    DarkPreview {
        VStack(spacing: SpacingTokens.md) {
            AlarmCard(alarm: AlarmCard.sampleAlarm, visualState: .active, isEnabled: $enabled1)
            AlarmCard(alarm: AlarmCard.sampleAlarmMonthly, visualState: .inactive, isEnabled: $enabled2)
            AlarmCard(alarm: AlarmCard.sampleAlarm, visualState: .snoozed, isEnabled: $enabled3)
        }
        .padding()
    }
}
