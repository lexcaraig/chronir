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

    /// Generated token spec (size, weight, design, Dynamic Type text style).
    var spec: TypographyTokens.Spec {
        switch self {
        case .displayAlarm: TypographyTokens.displayAlarmSpec
        case .headlineTime: TypographyTokens.headlineTimeSpec
        case .headlineTitle: TypographyTokens.headlineTitleSpec
        case .bodyPrimary: TypographyTokens.bodyPrimarySpec
        case .bodySecondary: TypographyTokens.bodySecondarySpec
        case .captionCountdown: TypographyTokens.captionCountdownSpec
        case .captionBadge: TypographyTokens.captionBadgeSpec
        case .displayLarge: TypographyTokens.displayLargeSpec
        case .displayMedium: TypographyTokens.displayMediumSpec
        case .displaySmall: TypographyTokens.displaySmallSpec
        case .headlineLarge: TypographyTokens.headlineLargeSpec
        case .headlineMedium: TypographyTokens.headlineMediumSpec
        case .headlineSmall: TypographyTokens.headlineSmallSpec
        case .titleLarge: TypographyTokens.titleLargeSpec
        case .titleMedium: TypographyTokens.titleMediumSpec
        case .titleSmall: TypographyTokens.titleSmallSpec
        case .bodyLarge: TypographyTokens.bodyLargeSpec
        case .bodyMedium: TypographyTokens.bodyMediumSpec
        case .bodySmall: TypographyTokens.bodySmallSpec
        case .labelLarge: TypographyTokens.labelLargeSpec
        case .labelMedium: TypographyTokens.labelMediumSpec
        case .labelSmall: TypographyTokens.labelSmallSpec
        case .caption: TypographyTokens.captionSpec
        }
    }

    /// Base size, weight, and design for each style (default Dynamic Type size, scale = 1.0).
    var baseAttributes: FontAttributes {
        FontAttributes(size: spec.size, weight: spec.weight, design: spec.design)
    }

    /// Unscaled font (no Dynamic Type, scale = 1.0). Used by widgets and backward-compat paths.
    var font: Font { spec.font }

    /// Font scaled by the in-app text-size multiplier only (no Dynamic Type).
    func font(scale: CGFloat) -> Font {
        TypographyTokens.scaled(size: spec.size, weight: spec.weight, design: spec.design, scale: scale)
    }

    /// Dynamic Type metric for this style — the base size scaled relative to its text style.
    var scaledMetric: ScaledMetric<CGFloat> {
        ScaledMetric(wrappedValue: spec.size, relativeTo: spec.textStyle)
    }
}

// MARK: - ChronirText View

struct ChronirText: View {
    let text: String
    var style: ChronirTextStyle
    var color: Color
    var maxLines: Int?
    var alignment: TextAlignment
    var minimumScaleFactor: CGFloat

    @Environment(\.textSizeScale) private var textSizeScale
    @ScaledMetric private var dynamicSize: CGFloat

    init(
        _ text: String,
        style: ChronirTextStyle = .bodyPrimary,
        color: Color = ColorTokens.textPrimary,
        maxLines: Int? = nil,
        alignment: TextAlignment = .leading,
        minimumScaleFactor: CGFloat = 1.0
    ) {
        self.text = text
        self.style = style
        self.color = color
        self.maxLines = maxLines
        self.alignment = alignment
        self.minimumScaleFactor = minimumScaleFactor
        _dynamicSize = style.scaledMetric
    }

    var body: some View {
        Text(text)
            .font(style.spec.font(size: style.spec.resolvedSize(dynamicSize: dynamicSize, appScale: textSizeScale)))
            .foregroundStyle(color)
            .lineLimit(maxLines)
            .multilineTextAlignment(alignment)
            .minimumScaleFactor(minimumScaleFactor)
    }
}

// MARK: - View Modifier for Direct .font() Call Sites

/// Applies a Chronir type style that scales with Dynamic Type, then by the in-app text-size preference.
struct ChronirFontModifier: ViewModifier {
    @Environment(\.textSizeScale) private var scale
    @ScaledMetric private var dynamicSize: CGFloat
    let style: ChronirTextStyle

    init(style: ChronirTextStyle) {
        self.style = style
        _dynamicSize = style.scaledMetric
    }

    func body(content: Content) -> some View {
        content.font(style.spec.font(size: style.spec.resolvedSize(dynamicSize: dynamicSize, appScale: scale)))
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

#Preview("Dynamic Type — Accessibility 3") {
    VStack(alignment: .leading, spacing: SpacingTokens.sm) {
        ChronirText("Screen Title", style: .headlineTitle)
        ChronirText("Primary body text", style: .bodyPrimary)
        ChronirText("Alarm in 6h 32m", style: .captionCountdown, color: ColorTokens.textSecondary)
        ChronirText("Caption", style: .caption, color: ColorTokens.textTertiary)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
    .dynamicTypeSize(.accessibility3)
}

#Preview("Dark") {
    DarkPreview {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText("Screen Title", style: .headlineTitle)
            ChronirText("Primary body text", style: .bodyPrimary)
            ChronirText("Secondary metadata", style: .bodySecondary, color: ColorTokens.textSecondary)
            ChronirText("Caption", style: .caption, color: ColorTokens.textTertiary)
        }
        .padding()
    }
}
