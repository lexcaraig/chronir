import SwiftUI

// MARK: - Environment Key

private struct TextSizeScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    var textSizeScale: CGFloat {
        get { self[TextSizeScaleKey.self] }
        set { self[TextSizeScaleKey.self] = newValue }
    }
}

// MARK: - Font Attributes

struct FontAttributes {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
}

// MARK: - Text Style

enum ChronirTextStyle {
    // Spec-aligned (design-system.md Section 3.3)
    case displayAlarm
    case headlineTime
    case headlineTitle
    case bodyPrimary
    case bodySecondary
    case captionCountdown
    case captionBadge

    // Full Material-style scale
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case headlineSmall
    case titleLarge
    case titleMedium
    case titleSmall
    case bodyLarge
    case bodyMedium
    case bodySmall
    case labelLarge
    case labelMedium
    case labelSmall
    case caption

    /// Base size, weight, and design for each style (scale = 1.0).
    var baseAttributes: FontAttributes {
        switch self {
        // Spec-aligned aliases resolve to their underlying token values
        case .displayAlarm, .displayLarge: FontAttributes(size: 120, weight: .bold, design: .rounded)
        case .displayMedium: FontAttributes(size: 57, weight: .bold, design: .rounded)
        case .displaySmall: FontAttributes(size: 36, weight: .bold, design: .rounded)
        case .headlineLarge: FontAttributes(size: 32, weight: .semibold, design: .default)
        case .headlineMedium: FontAttributes(size: 28, weight: .semibold, design: .default)
        case .headlineSmall, .headlineTime, .headlineTitle:
            FontAttributes(size: 24, weight: .semibold, design: .default)
        case .titleLarge: FontAttributes(size: 22, weight: .medium, design: .default)
        case .titleMedium: FontAttributes(size: 18, weight: .medium, design: .default)
        case .titleSmall: FontAttributes(size: 16, weight: .medium, design: .default)
        case .bodyLarge, .bodyPrimary: FontAttributes(size: 16, weight: .regular, design: .default)
        case .bodyMedium, .bodySecondary: FontAttributes(size: 14, weight: .regular, design: .default)
        case .bodySmall: FontAttributes(size: 12, weight: .regular, design: .default)
        case .labelLarge, .captionCountdown: FontAttributes(size: 14, weight: .medium, design: .default)
        case .labelMedium, .captionBadge: FontAttributes(size: 12, weight: .medium, design: .default)
        case .labelSmall: FontAttributes(size: 11, weight: .medium, design: .default)
        case .caption: FontAttributes(size: 10, weight: .regular, design: .default)
        }
    }

    /// Unscaled font (scale = 1.0). Used by widgets and backward-compat paths.
    var font: Font {
        let attr = baseAttributes
        return Font.system(size: attr.size, weight: attr.weight, design: attr.design)
    }

    /// Scaled font using the given scale factor.
    func font(scale: CGFloat) -> Font {
        let attr = baseAttributes
        return TypographyTokens.scaled(size: attr.size, weight: attr.weight, design: attr.design, scale: scale)
    }
}

// MARK: - ChronirText View

struct ChronirText: View {
    let text: String
    var style: ChronirTextStyle
    var color: Color
    var maxLines: Int?
    var alignment: TextAlignment

    @Environment(\.textSizeScale) private var textSizeScale

    init(
        _ text: String,
        style: ChronirTextStyle = .bodyPrimary,
        color: Color = ColorTokens.textPrimary,
        maxLines: Int? = nil,
        alignment: TextAlignment = .leading
    ) {
        self.text = text
        self.style = style
        self.color = color
        self.maxLines = maxLines
        self.alignment = alignment
    }

    var body: some View {
        Text(text)
            .font(style.font(scale: textSizeScale))
            .foregroundStyle(color)
            .lineLimit(maxLines)
            .multilineTextAlignment(alignment)
    }
}

// MARK: - View Modifier for Direct .font() Call Sites

struct ChronirFontModifier: ViewModifier {
    @Environment(\.textSizeScale) private var scale
    let style: ChronirTextStyle

    func body(content: Content) -> some View {
        content.font(style.font(scale: scale))
    }
}

extension View {
    func chronirFont(_ style: ChronirTextStyle) -> some View {
        modifier(ChronirFontModifier(style: style))
    }
}

// MARK: - Previews

#Preview("Spec-Aligned Variants") {
    VStack(alignment: .leading, spacing: SpacingTokens.md) {
        ChronirText("12:00", style: .displayAlarm)
        ChronirText("3:45 PM", style: .headlineTime)
        ChronirText("Screen Title", style: .headlineTitle)
        ChronirText("Primary body text", style: .bodyPrimary)
        ChronirText("Secondary metadata", style: .bodySecondary, color: ColorTokens.textSecondary)
        ChronirText("Alarm in 6h 32m", style: .captionCountdown)
        ChronirText("Weekly", style: .captionBadge, color: ColorTokens.textSecondary)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Full Type Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText("Display Large", style: .displayLarge)
            ChronirText("Display Medium", style: .displayMedium)
            ChronirText("Display Small", style: .displaySmall)
            ChronirText("Headline Large", style: .headlineLarge)
            ChronirText("Headline Medium", style: .headlineMedium)
            ChronirText("Headline Small", style: .headlineSmall)
            ChronirText("Title Large", style: .titleLarge)
            ChronirText("Title Medium", style: .titleMedium)
            ChronirText("Title Small", style: .titleSmall)
            ChronirText("Body Large", style: .bodyLarge)
            ChronirText("Body Medium", style: .bodyMedium)
            ChronirText("Body Small", style: .bodySmall)
            ChronirText("Label Large", style: .labelLarge)
            ChronirText("Label Medium", style: .labelMedium)
            ChronirText("Label Small", style: .labelSmall)
            ChronirText("Caption", style: .caption)
        }
        .padding()
    }
    .background(ColorTokens.backgroundPrimary)
}
