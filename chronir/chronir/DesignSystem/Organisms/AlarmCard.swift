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
        case .inactive: return ("Off", ColorTokens.badgeNeutralBackground, "pause.circle")
        case .snoozed: return ("Snoozed", ColorTokens.badgeWarningBackground, "zzz")
        case .pending: return ("Awaiting Confirmation", ColorTokens.badgeInfoBackground, "clock.badge.questionmark")
        }
    }

    /// Text color for `statusBadge.color` (contrast-checked pair).
    var statusBadgeForeground: Color? {
        switch self {
        case .active: return nil
        case .inactive: return ColorTokens.badgeNeutralForeground
        case .snoozed: return ColorTokens.badgeWarningForeground
        case .pending: return ColorTokens.badgeInfoForeground
        }
    }
}

struct AlarmCard: View {
    let alarm: Alarm
    let visualState: AlarmVisualState
    @Binding var isEnabled: Bool
    var streak: Int = 0
    var isPlusUser: Bool = false
    /// AlarmKit rejected the last registration: the alarm will not ring until it is scheduled again.
    var isUnscheduled: Bool = false

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
        } else if cal.isDate(date, equalTo: now, toGranularity: .year) {
            return "Last completed: \(date.formatted(.dateTime.month(.abbreviated).day()))"
        } else {
            return "Last completed: \(date.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
    }

    /// Streak tiers: gold (10+), green (5+), neutral. Fill + contrast-checked text.
    private var streakBadgeColors: (background: Color, foreground: Color) {
        if streak >= 10 { return (ColorTokens.badgeVehicleBackground, ColorTokens.badgeVehicleForeground) } // amber
        if streak >= 5 { return (ColorTokens.badgeFinanceBackground, ColorTokens.badgeFinanceForeground) } // green
        return (ColorTokens.badgeSuccessBackground, ColorTokens.badgeSuccessForeground)
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

    private var multipleTimesBadge: some View {
        ChronirBadge(
            "+\(alarm.timesOfDay.count - 1)",
            color: ColorTokens.badgeNeutralBackground,
            foreground: ColorTokens.badgeNeutralForeground
        )
        .accessibilityLabel("\(alarm.timesOfDay.count) times a day")
    }

    /// Schedule, category and status badges. Shared by the one-line and stacked layouts.
    @ViewBuilder
    private var statusBadges: some View {
        ChronirBadge(schedule: alarm.schedule)
        if let cat = alarm.alarmCategory {
            ChronirBadge(cat.displayName, category: cat)
        }
        if let badge = visualState.statusBadge {
            ChronirBadge(
                badge.text,
                color: badge.color,
                icon: badge.icon,
                foreground: visualState.statusBadgeForeground
            )
        }
        if isUnscheduled && visualState != .inactive {
            ChronirBadge(
                "Not scheduled",
                color: ColorTokens.badgeErrorBackground,
                icon: "exclamationmark.triangle.fill",
                foreground: ColorTokens.badgeErrorForeground
            )
        }
    }

    @ViewBuilder
    private var timeDisplay: some View {
        HStack(alignment: .firstTextBaseline) {
            if visualState != .inactive {
                AlarmTimeDisplay(
                    time: alarm.nextFireDate,
                    countdownText: countdownText
                )
            } else {
                ChronirText(
                    alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                    style: .headlineTime,
                    color: ColorTokens.textSecondary
                )
            }
            if alarm.hasMultipleTimes {
                multipleTimesBadge
            }
        }
    }

    @ViewBuilder
    private var trailingBadges: some View {
        if isPlusUser && streak >= 2 {
            ChronirBadge(
                "\(streak) streak",
                color: streakBadgeColors.background,
                icon: streakBadgeIcon,
                foreground: streakBadgeColors.foreground
            )
        } else if !isPlusUser && streak >= 3 {
            ChronirBadge(
                "streak",
                color: ColorTokens.badgeNeutralBackground,
                foreground: ColorTokens.badgeNeutralForeground
            )
        }
        if alarm.isPersistent {
            ChronirBadge(
                "Persistent",
                color: ColorTokens.badgeWarningBackground,
                icon: "bell.badge.fill",
                foreground: ColorTokens.badgeWarningForeground
            )
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
                            // Inactive alarms stay readable (textSecondary passes 4.5:1); the "Off"
                            // badge and the toggle carry the state.
                            color: visualState == .inactive ? ColorTokens.textSecondary : ColorTokens.textPrimary
                        )
                        // Badges never truncate, so they stack when one line can't hold them
                        // (accessibility text sizes, long category names).
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: SpacingTokens.xxs) { statusBadges }
                            VStack(alignment: .leading, spacing: SpacingTokens.xxs) { statusBadges }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    Spacer()
                    // The label stays hidden on screen but names the switch for VoiceOver.
                    Toggle(alarm.title, isOn: $isEnabled)
                        .tint(ColorTokens.toggleOn)
                        .labelsHidden()
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline) {
                        timeDisplay
                        Spacer()
                        HStack(spacing: SpacingTokens.xxs) { trailingBadges }
                    }
                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        timeDisplay
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: SpacingTokens.xxs) { trailingBadges }
                            VStack(alignment: .leading, spacing: SpacingTokens.xxs) { trailingBadges }
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                if let text = lastCompletedText {
                    ChronirText(text, style: .bodySmall, color: ColorTokens.textTertiary)
                }
            }
            .padding(SpacingTokens.cardPadding)
            .chronirGlassCard()
            .overlay(
                RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                    .stroke(
                        visualState.accentColor ?? .clear,
                        lineWidth: visualState.accentColor != nil ? SpacingTokens.statusStroke : 0
                    )
            )
            .accessibilityElement(children: .contain)
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

#Preview("Not Scheduled") {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: AlarmCard.sampleAlarm,
        visualState: .active,
        isEnabled: $isEnabled,
        isUnscheduled: true
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Accessibility Text Size") {
    @Previewable @State var isEnabled = true
    AlarmCard(
        alarm: AlarmCard.sampleAlarmMonthly,
        visualState: .pending,
        isEnabled: $isEnabled,
        streak: 12,
        isPlusUser: true,
        isUnscheduled: true
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
    .dynamicTypeSize(.accessibility3)
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
            AlarmCard(alarm: AlarmCard.sampleAlarm, visualState: .active, isEnabled: $enabled1, isUnscheduled: true)
        }
        .padding()
    }
}

#Preview("Liquid Glass") {
    @Previewable @State var isEnabled = true
    GlassPreview {
        AlarmCard(
            alarm: AlarmCard.sampleAlarm,
            visualState: .active,
            isEnabled: $isEnabled,
            streak: 12,
            isPlusUser: true
        )
            .padding()
    }
}
