import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Values sourced from design-tokens/tokens/color.json (Style Dictionary)
// See docs/design-system.md Section 3.2 for full spec
//
// Semantic tokens use adaptive UIColor providers so they automatically
// resolve to light or dark values based on the current color scheme.
// Liquid Glass and Dark both use .dark color scheme — glass tokens are
// translucent fallbacks, Dark tokens are opaque surfaces.

enum ColorTokens {
    // MARK: - Primitive (non-adaptive)

    static let amber500 = Color(hex: 0xFFB800)
    static let blue500 = Color(hex: 0x3B82F6)
    static let blue600 = Color(hex: 0x2563EB)
    static let blue700 = Color(hex: 0x1D4ED8)
    static let red400 = Color(hex: 0xF87171)
    static let red500 = Color(hex: 0xEF4444)
    static let green500 = Color(hex: 0x22C55E)
    static let purple500 = Color(hex: 0x8B5CF6)
    static let gray50 = Color(hex: 0xF8F9FA)
    static let gray100 = Color(hex: 0xF1F3F5)
    static let gray400 = Color(hex: 0x9CA3AF)
    static let gray800 = Color(hex: 0x1C1C1E)
    static let gray900 = Color(hex: 0x111111)
    static let offWhite = Color(hex: 0xF5F5F5)

    // MARK: - Accent (non-adaptive)

    static let secondary = purple500

    // MARK: - Semantic (non-adaptive)

    static let success = green500
    static let warning = amber500
    static let error = red500
    static let info = blue500

    // MARK: - Adaptive Semantic

    static let primary = adaptive(light: 0x3B3D42, dark: 0xBFC1C4)

    static let textPrimary = adaptive(light: 0x1E1F21, dark: 0xE2E3E4)
    static let textSecondary = adaptive(light: 0x6B6E76, dark: 0x96999E)
    static let textTertiary = adaptive(light: 0x8C8F97, dark: 0x63666B)
    static let textDisabled = adaptive(light: 0xB7B9BE, dark: 0x4B4D51)

    static let backgroundPrimary = adaptive(light: 0xF2F2F7, dark: 0x242528)
    static let backgroundSecondary = adaptive(light: 0xE5E5EA, dark: 0x1F1F21)
    static let backgroundTertiary = adaptive(light: 0xD1D1D6, dark: 0x3D3F43)

    static let surfaceCard = adaptive(light: 0xFFFFFF, dark: 0x303134)
    static let surfaceElevated = adaptive(light: 0xFFFFFF, dark: 0x1F1F21)
    static let surfacePrimary = adaptive(light: 0xF8F8F8, dark: 0x242528)

    static let borderDefault = adaptive(light: 0xDDDEE1, dark: 0x303134)
    static let borderFocused = adaptive(light: 0x3B3D42, dark: 0x96999E)

    static let iconPrimary = adaptive(light: 0x3B3D42, dark: 0xBFC1C4)
    static let iconSecondary = adaptive(light: 0x7D8088, dark: 0x7D8088)

    // MARK: - Alarm State (non-adaptive)

    static let alarmActiveBackground = amber500
    static let alarmActiveForeground = gray900
    static let alarmInactiveBackground = gray100
    static let alarmInactiveForeground = gray400

    // MARK: - Firing Screen (non-adaptive — always dark)

    static let firingBackground = Color.black
    static let firingForeground = offWhite

    // MARK: - Cycle Badges (adaptive neutral — solid bg + white text)
    // Values from CSS: --accent, --badge-monthly, --badge-annual, --badge-custom

    static let badgeWeekly = adaptive(light: 0x1E1F21, dark: 0x96999E)
    static let badgeMonthly = adaptive(light: 0x55565C, dark: 0x96999E)
    static let badgeAnnual = adaptive(light: 0x55565C, dark: 0x96999E)
    static let badgeCustom = adaptive(light: 0x55565C, dark: 0x96999E)
    static let badgeOneTime = adaptive(light: 0x55565C, dark: 0x96999E)

    // MARK: - Badge Status (adaptive neutral — for status badges in cards)
    // Values from CSS: --color-warning, --color-success, --color-error

    static let badgeWarning = adaptive(light: 0x55565C, dark: 0x96999E)
    static let badgeSuccess = adaptive(light: 0x4A4B50, dark: 0x8A8B90)
    static let badgeError = red500

    // MARK: - Category Colors (vivid — used for icons and category group cards)

    static let categoryHome = blue500
    static let categoryHealth = red400
    static let categoryFinance = green500
    static let categoryVehicle = amber500
    static let categoryWork = purple500
    static let categoryPersonal = blue600
    static let categoryPets = amber500
    static let categorySubscriptions = red500

    // MARK: - Action Buttons (adaptive)

    static let buttonSnooze = adaptive(light: 0xD97706, dark: 0xFFB800)
    static let buttonDismiss = adaptive(light: 0x16A34A, dark: 0x22C55E)
    static let buttonDestructive = adaptive(light: 0xDC2626, dark: 0xEF4444)

    // MARK: - Background Gradient (non-adaptive — Liquid Glass only)

    static let gradientStart = Color(hex: 0x0A1628)
    static let gradientMid = Color(hex: 0x0C4A6E)
    static let gradientEnd = Color(hex: 0x06B6D4)

    static let backgroundGradient = LinearGradient(
        colors: [gradientStart, gradientMid, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Adaptive Helper

    private static func adaptive(light: UInt, dark: UInt) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(
                    red: CGFloat((dark >> 16) & 0xFF) / 255,
                    green: CGFloat((dark >> 8) & 0xFF) / 255,
                    blue: CGFloat(dark & 0xFF) / 255,
                    alpha: 1
                )
            } else {
                return UIColor(
                    red: CGFloat((light >> 16) & 0xFF) / 255,
                    green: CGFloat((light >> 8) & 0xFF) / 255,
                    blue: CGFloat(light & 0xFF) / 255,
                    alpha: 1
                )
            }
        })
        #else
        return Color(hex: dark)
        #endif
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
