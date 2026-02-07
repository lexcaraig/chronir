import SwiftUI

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

    var font: Font {
        switch self {
        // Spec-aligned
        case .displayAlarm: return TypographyTokens.displayAlarm
        case .headlineTime: return TypographyTokens.headlineTime
        case .headlineTitle: return TypographyTokens.headlineTitle
        case .bodyPrimary: return TypographyTokens.bodyPrimary
        case .bodySecondary: return TypographyTokens.bodySecondary
        case .captionCountdown: return TypographyTokens.captionCountdown
        case .captionBadge: return TypographyTokens.captionBadge
        // Full scale
        case .displayLarge: return TypographyTokens.displayLarge
        case .displayMedium: return TypographyTokens.displayMedium
        case .displaySmall: return TypographyTokens.displaySmall
        case .headlineLarge: return TypographyTokens.headlineLarge
        case .headlineMedium: return TypographyTokens.headlineMedium
        case .headlineSmall: return TypographyTokens.headlineSmall
        case .titleLarge: return TypographyTokens.titleLarge
        case .titleMedium: return TypographyTokens.titleMedium
        case .titleSmall: return TypographyTokens.titleSmall
        case .bodyLarge: return TypographyTokens.bodyLarge
        case .bodyMedium: return TypographyTokens.bodyMedium
        case .bodySmall: return TypographyTokens.bodySmall
        case .labelLarge: return TypographyTokens.labelLarge
        case .labelMedium: return TypographyTokens.labelMedium
        case .labelSmall: return TypographyTokens.labelSmall
        case .caption: return TypographyTokens.caption
        }
    }
}

struct ChronirText: View {
    let text: String
    var style: ChronirTextStyle
    var color: Color
    var maxLines: Int?
    var alignment: TextAlignment

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
            .font(style.font)
            .foregroundStyle(color)
            .lineLimit(maxLines)
            .multilineTextAlignment(alignment)
    }
}

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
