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

    var body: some View {
        Text(text)
            .font(TypographyTokens.labelSmall)
            .foregroundStyle(.white)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xs)
            .background(color)
            .clipShape(Capsule())
    }

    private static func color(for cycleType: CycleType) -> Color {
        switch cycleType {
        case .weekly: return ColorTokens.badgeWeekly
        case .monthly: return ColorTokens.badgeMonthly
        case .yearly: return ColorTokens.badgeAnnual
        case .custom: return ColorTokens.badgeCustom
        case .daily: return ColorTokens.primary
        case .biweekly: return ColorTokens.primary
        case .quarterly: return ColorTokens.secondary
        }
    }
}

#Preview("Cycle Type Badges") {
    HStack(spacing: SpacingTokens.sm) {
        ChronirBadge(cycleType: .weekly)
        ChronirBadge(cycleType: .monthly)
        ChronirBadge(cycleType: .yearly)
        ChronirBadge(cycleType: .custom)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Custom Badges") {
    HStack(spacing: SpacingTokens.sm) {
        ChronirBadge("Active", color: ColorTokens.success)
        ChronirBadge("Persistent", color: ColorTokens.warning)
        ChronirBadge("Owner", color: ColorTokens.secondary)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
