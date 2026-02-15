import SwiftUI

struct ChronirBadge: View {
    let text: String
    var color: Color

    init(_ text: String, color: Color = ColorTokens.primary) {
        self.text = text
        self.color = color
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
        Text(text)
            .chronirFont(.labelSmall)
            .foregroundStyle(.white)
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
        ChronirBadge("Persistent", color: ColorTokens.badgeWarning)
        ChronirBadge("Missed", color: ColorTokens.badgeError)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
