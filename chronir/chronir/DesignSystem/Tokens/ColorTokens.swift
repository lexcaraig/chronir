import SwiftUI

// Values sourced from design-tokens/tokens/color.json (Style Dictionary)
// See docs/design-system.md Section 3.2 for full spec

enum ColorTokens {
    // MARK: - Primitive

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

    // MARK: - Accent

    static let primary = blue500
    static let primaryHover = blue600
    static let primaryDark = blue700
    static let secondary = purple500

    // MARK: - Semantic

    static let success = green500
    static let warning = amber500
    static let error = red500
    static let info = blue500

    // MARK: - Surface

    static let surfacePrimary = gray50
    static let surfaceElevated = Color.white
    static let backgroundPrimary = gray800
    static let backgroundSecondary = gray900
    static let backgroundTertiary = Color(hex: 0x2C2C2E)
    static let surfaceCard = Color(hex: 0x2C2C2E)

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = gray400
    static let textTertiary = Color(hex: 0x64748B)
    static let textDisabled = Color(hex: 0x475569)

    // MARK: - Border

    static let borderDefault = Color(hex: 0x334155)
    static let borderFocused = blue500

    // MARK: - Alarm State

    static let alarmActiveBackground = amber500
    static let alarmActiveForeground = gray900
    static let alarmInactiveBackground = gray100
    static let alarmInactiveForeground = gray400

    // MARK: - Firing Screen

    static let firingBackground = Color.black
    static let firingForeground = offWhite

    // MARK: - Cycle Badges

    static let badgeWeekly = blue500
    static let badgeMonthly = amber500
    static let badgeAnnual = red400
    static let badgeCustom = purple500

    // MARK: - Action Buttons

    static let buttonSnooze = amber500
    static let buttonDismiss = green500
    static let buttonDestructive = red500

    // MARK: - Background Gradient

    static let gradientStart = Color(hex: 0x1A0533)
    static let gradientMid = Color(hex: 0x3D1444)
    static let gradientEnd = Color(hex: 0x6B2030)

    static let backgroundGradient = LinearGradient(
        colors: [gradientStart, gradientMid, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
