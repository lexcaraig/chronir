import SwiftUI

struct ChronirBadge: View {
    let text: String
    var color: Color
    var icon: String?
    /// Text/icon color. `nil` picks the higher-contrast of light or dark text for `color`
    /// in the current appearance, so legacy `color:`-only call sites stay legible.
    var foreground: Color?

    @Environment(\.self) private var environment

    init(_ text: String, color: Color = ColorTokens.primary, icon: String? = nil, foreground: Color? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
        self.foreground = foreground
    }

    init(cycleType: CycleType) {
        let pair = Self.pair(for: cycleType)
        self.text = cycleType.displayName
        self.color = pair.background
        self.foreground = pair.foreground
    }

    init(schedule: Schedule) {
        let pair = Self.pair(for: schedule.cycleType)
        self.text = schedule.displayName
        self.color = pair.background
        self.foreground = pair.foreground
    }

    /// Category badge using the category's contrast-checked badge pair.
    init(_ text: String, category: AlarmCategory, icon: String? = nil) {
        self.text = text
        let pair = Self.pair(for: category)
        self.icon = icon
        self.color = pair.background
        self.foreground = pair.foreground
    }

    var body: some View {
        HStack(spacing: SpacingTokens.xxs) {
            if let icon {
                Image(systemName: icon)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .chronirFont(.labelSmall)
        .fontWeight(.semibold)
        .foregroundStyle(foreground ?? Self.onColor(for: color, in: environment))
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, SpacingTokens.sm)
        .padding(.vertical, SpacingTokens.xs)
        .background(color, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Pairs

    private static func pair(for cycleType: CycleType) -> (background: Color, foreground: Color) {
        switch cycleType {
        case .weekly: return (ColorTokens.badgeWeeklyBackground, ColorTokens.badgeWeeklyForeground)
        case .monthlyDate, .monthlyRelative:
            return (ColorTokens.badgeMonthlyBackground, ColorTokens.badgeMonthlyForeground)
        case .annual: return (ColorTokens.badgeAnnualBackground, ColorTokens.badgeAnnualForeground)
        case .customDays: return (ColorTokens.badgeCustomBackground, ColorTokens.badgeCustomForeground)
        case .oneTime: return (ColorTokens.badgeOneTimeBackground, ColorTokens.badgeOneTimeForeground)
        }
    }

    static func pair(for category: AlarmCategory) -> (background: Color, foreground: Color) {
        switch category {
        case .home: return (ColorTokens.badgeHomeBackground, ColorTokens.badgeHomeForeground)
        case .health: return (ColorTokens.badgeHealthBackground, ColorTokens.badgeHealthForeground)
        case .finance: return (ColorTokens.badgeFinanceBackground, ColorTokens.badgeFinanceForeground)
        case .vehicle: return (ColorTokens.badgeVehicleBackground, ColorTokens.badgeVehicleForeground)
        case .work: return (ColorTokens.badgeWorkBackground, ColorTokens.badgeWorkForeground)
        case .personal: return (ColorTokens.badgePersonalBackground, ColorTokens.badgePersonalForeground)
        case .pets: return (ColorTokens.badgePetsBackground, ColorTokens.badgePetsForeground)
        case .subscriptions: return (ColorTokens.badgeSubscriptionsBackground, ColorTokens.badgeSubscriptionsForeground)
        }
    }

    /// Higher-contrast foreground (`onDarkFill` white vs. `onLightFill` near-black) for an arbitrary fill,
    /// resolved for the current appearance. WCAG 2.x relative luminance.
    static func onColor(for fill: Color, in environment: EnvironmentValues) -> Color {
        let resolved = fill.resolve(in: environment)
        let luminance = 0.2126 * Double(resolved.linearRed)
            + 0.7152 * Double(resolved.linearGreen)
            + 0.0722 * Double(resolved.linearBlue)
        let darkTextLuminance = 0.0137 // #1E1F21
        let contrastWithWhite = 1.05 / (luminance + 0.05)
        let contrastWithDark = (luminance + 0.05) / (darkTextLuminance + 0.05)
        return contrastWithWhite >= contrastWithDark ? ColorTokens.onDarkFill : ColorTokens.onLightFill
    }
}

private struct ChronirBadgeGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.sm) {
                ChronirBadge(cycleType: .weekly)
                ChronirBadge(cycleType: .monthlyDate)
                ChronirBadge(cycleType: .annual)
                ChronirBadge(cycleType: .oneTime)
            }
            HStack(spacing: SpacingTokens.sm) {
                ChronirBadge(
                    "Active",
                    color: ColorTokens.badgeSuccessBackground,
                    foreground: ColorTokens.badgeSuccessForeground
                )
                ChronirBadge("Persistent", color: ColorTokens.badgeWarning, icon: "bell.badge.fill")
                ChronirBadge("Missed", color: ColorTokens.badgeError, icon: "exclamationmark.triangle.fill")
            }
            HStack(spacing: SpacingTokens.sm) {
                ChronirBadge("Home", category: .home)
                ChronirBadge("Work", category: .work)
                ChronirBadge("Pets", category: .pets)
                ChronirBadge(
                    "+2",
                    color: ColorTokens.badgeNeutralBackground,
                    foreground: ColorTokens.badgeNeutralForeground
                )
            }
        }
        .padding()
    }
}

#Preview("Light") {
    ChronirBadgeGallery()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { ChronirBadgeGallery() }
}
