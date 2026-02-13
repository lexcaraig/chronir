import SwiftUI

struct CompletionLogRow: View {
    let log: CompletionLog
    let alarmTitle: String?

    private var actionIcon: String {
        switch log.action {
        case .completed: return "checkmark.circle.fill"
        case .snoozed: return "zzz"
        case .dismissed: return "xmark.circle.fill"
        }
    }

    private var actionColor: Color {
        switch log.action {
        case .completed: return ColorTokens.success
        case .snoozed: return ColorTokens.warning
        case .dismissed: return ColorTokens.error
        }
    }

    private var actionLabel: String {
        switch log.action {
        case .completed: return "Completed"
        case .snoozed: return "Snoozed"
        case .dismissed: return "Dismissed"
        }
    }

    var body: some View {
        HStack(spacing: SpacingTokens.md) {
            Image(systemName: actionIcon)
                .foregroundStyle(actionColor)
                .font(.title3)
                .frame(width: 28)

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
                        color: ColorTokens.warning
                    )
                }
                ChronirBadge(actionLabel, color: actionColor)
            }
        }
        .padding(.vertical, SpacingTokens.xs)
    }
}
