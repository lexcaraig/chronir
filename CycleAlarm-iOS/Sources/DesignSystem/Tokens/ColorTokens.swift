import SwiftUI

enum ColorTokens {
    // MARK: - Primary
    static let primary = Color(hex: 0x6366F1)
    static let primaryLight = Color(hex: 0x818CF8)
    static let primaryDark = Color(hex: 0x4F46E5)

    // MARK: - Secondary
    static let secondary = Color(hex: 0x8B5CF6)
    static let secondaryLight = Color(hex: 0xA78BFA)
    static let secondaryDark = Color(hex: 0x7C3AED)

    // MARK: - Semantic
    static let success = Color(hex: 0x22C55E)
    static let warning = Color(hex: 0xF59E0B)
    static let error = Color(hex: 0xEF4444)
    static let info = Color(hex: 0x3B82F6)

    // MARK: - Neutral
    static let backgroundPrimary = Color(hex: 0x0F172A)
    static let backgroundSecondary = Color(hex: 0x1E293B)
    static let backgroundTertiary = Color(hex: 0x334155)
    static let surfaceCard = Color(hex: 0x1E293B)
    static let surfaceElevated = Color(hex: 0x334155)

    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textTertiary = Color(hex: 0x64748B)
    static let textDisabled = Color(hex: 0x475569)

    // MARK: - Border
    static let borderDefault = Color(hex: 0x334155)
    static let borderFocused = Color(hex: 0x6366F1)
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
