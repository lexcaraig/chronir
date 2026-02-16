import SwiftUI

/// Minimal design token subset for widgets.
/// Widgets can't use UIKit adaptive colors or glass effects,
/// so these are static SwiftUI Color values.
enum WidgetTokens {
    // MARK: - Colors

    static let primary = Color(hex: 0x3B3D42)
    static let primaryDark = Color(hex: 0xBFC1C4)

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(hex: 0x8C8F97)

    static let backgroundPrimary = Color(hex: 0xF2F2F7)
    static let backgroundDark = Color(hex: 0x242528)

    static let surfaceCard = Color(hex: 0xFFFFFF)
    static let surfaceCardDark = Color(hex: 0x303134)

    static let accent = Color(hex: 0xFFB800)

    // MARK: - Category Colors

    static func categoryColor(for name: String?) -> Color {
        guard let name else { return Color(hex: 0x3B82F6) }
        switch name {
        case "home": return Color(hex: 0x3B82F6)
        case "health": return Color(hex: 0xF87171)
        case "finance": return Color(hex: 0x22C55E)
        case "vehicle": return Color(hex: 0xFFB800)
        case "work": return Color(hex: 0x8B5CF6)
        case "personal": return Color(hex: 0x2563EB)
        case "pets": return Color(hex: 0xFFB800)
        case "subscriptions": return Color(hex: 0xEF4444)
        default: return Color(hex: 0x3B82F6)
        }
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
}

// Color hex initializer (duplicated here since widget extension can't import main app)
extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
