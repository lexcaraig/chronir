import SwiftUI

struct CompletionLogRow: View {
    let log: CompletionLog
    let alarmTitle: String?

    private var actionIcon: String {
        switch log.action {
        case .completed: return "checkmark.circle.fill"
        case .snoozed: return "zzz"
        case .dismissed: return "xmark.circle.fill"
        case .skipped: return "forward.end.fill"
        case .pendingConfirmation: return "clock.badge.questionmark"
        }
    }

    /// Badge fill + text pair (>= 4.5:1). The fill doubles as the leading icon tint.
    private var actionColors: (background: Color, foreground: Color) {
        switch log.action {
        case .completed: return (ColorTokens.badgeSuccessBackground, ColorTokens.badgeSuccessForeground)
        case .snoozed: return (ColorTokens.badgeWarningBackground, ColorTokens.badgeWarningForeground)
        case .dismissed: return (ColorTokens.badgeErrorBackground, ColorTokens.badgeErrorForeground)
        case .skipped: return (ColorTokens.badgeNeutralBackground, ColorTokens.badgeNeutralForeground)
        case .pendingConfirmation: return (ColorTokens.badgeInfoBackground, ColorTokens.badgeInfoForeground)
        }
    }

    private var actionLabel: String {
        switch log.action {
        case .completed: return "Completed"
        case .snoozed: return "Snoozed"
        case .dismissed: return "Dismissed"
        case .skipped: return "Skipped"
        case .pendingConfirmation: return "Awaiting Confirmation"
        }
    }

    var body: some View {
        HStack(spacing: SpacingTokens.md) {
            Image(systemName: actionIcon)
                .foregroundStyle(log.action == .skipped ? ColorTokens.textSecondary : actionColors.background)
                .font(.title3)
                .frame(minWidth: SpacingTokens.lg + SpacingTokens.xxs)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                if let title = alarmTitle {
                    ChronirText(title, style: .bodyPrimary)
                }
                ChronirText(
                    log.completedAt.formatted(date: .omitted, time: .shortened),
                    style: .bodySecondary,
                    color: ColorTokens.textSecondary
                )
            }

            Spacer()

            HStack(spacing: SpacingTokens.xs) {
                if log.snoozeCount > 0 {
                    ChronirBadge(
                        "\(log.snoozeCount)x snoozed",
                        color: ColorTokens.badgeWarningBackground,
                        foreground: ColorTokens.badgeWarningForeground
                    )
                }
                ChronirBadge(
                    actionLabel,
                    color: actionColors.background,
                    icon: actionIcon,
                    foreground: actionColors.foreground
                )
            }
        }
        .padding(.vertical, SpacingTokens.xs)
        .accessibilityElement(children: .combine)
    }
}

private struct CompletionLogRowGallery: View {
    var body: some View {
        List {
            CompletionLogRow(log: CompletionLog(alarmID: UUID(), action: .completed), alarmTitle: "Pay Rent")
            CompletionLogRow(
                log: CompletionLog(alarmID: UUID(), action: .snoozed, snoozeCount: 2),
                alarmTitle: "Renew Passport"
            )
            CompletionLogRow(log: CompletionLog(alarmID: UUID(), action: .skipped), alarmTitle: nil)
            CompletionLogRow(log: CompletionLog(alarmID: UUID(), action: .pendingConfirmation), alarmTitle: "Vet Visit")
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview("Light") {
    CompletionLogRowGallery()
}

#Preview("Dark") {
    CompletionLogRowGallery()
        .environment(\.colorScheme, .dark)
}
