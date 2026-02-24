import SwiftUI

struct ChronirBadge: View {
    let text: String
    var color: Color
    var icon: String?

    init(_ text: String, color: Color = ColorTokens.primary, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }

    init(cycleType: CycleType) {
        self.text = cycleType.displayName
        self.color = Self.color(for: cycleType)
    }

    init(schedule: Schedule) {
        self.text = schedule.displayName
        self.color = Self.color(for: schedule.cycleType)
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .chronirFont(.labelSmall)
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, SpacingTokens.sm)
        .padding(.vertical, SpacingTokens.xs)
        .background(color)
        .clipShape(Capsule())
    }

    private static func color(for cycleType: CycleType) -> Color {
        switch cycleType {
        case .weekly: return ColorTokens.badgeWeekly
        case .monthlyDate, .monthlyRelative: return ColorTokens.badgeMonthly
        case .annual: return ColorTokens.badgeAnnual
        case .customDays: return ColorTokens.badgeCustom
        case .oneTime: return ColorTokens.badgeOneTime
        }
    }
}

#Preview("Cycle Type Badges") {
    HStack(spacing: SpacingTokens.sm) {
        ChronirBadge(cycleType: .weekly)
        ChronirBadge(cycleType: .monthlyDate)
        ChronirBadge(cycleType: .annual)
        ChronirBadge(cycleType: .customDays)
        ChronirBadge(cycleType: .oneTime)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Status Badges") {
    HStack(spacing: SpacingTokens.sm) {
        ChronirBadge("Active", color: ColorTokens.badgeSuccess)
        ChronirBadge("Persistent", color: ColorTokens.badgeWarning, icon: "bell.badge.fill")
        ChronirBadge("Missed", color: ColorTokens.badgeError, icon: "exclamationmark.triangle.fill")
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
