import SwiftUI

// Values sourced from design-tokens/tokens/typography.json (Style Dictionary)
// See docs/design-system.md Section 3.3 for full spec

enum TypographyTokens {
    // MARK: - Display

    static let displayLarge = Font.system(size: 120, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 57, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: - Headline

    static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)

    // MARK: - Title

    static let titleLarge = Font.system(size: 22, weight: .medium, design: .default)
    static let titleMedium = Font.system(size: 18, weight: .medium, design: .default)
    static let titleSmall = Font.system(size: 16, weight: .medium, design: .default)

    // MARK: - Body

    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - Label

    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Caption

    static let caption = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Spec-Aligned Aliases (design-system.md Section 3.3)

    static let displayAlarm = displayLarge          // 120pt firing screen time
    static let headlineTime = headlineSmall           // 24pt alarm card time
    static let headlineTitle = headlineSmall          // 24pt screen titles
    static let bodyPrimary = bodyLarge               // 16pt labels, descriptions
    static let bodySecondary = bodyMedium             // 14pt metadata
    static let captionCountdown = labelLarge          // 14pt "Alarm in 6h 32m"
    static let captionBadge = labelMedium             // 12pt cycle type badges

    // MARK: - Scaling

    static func scaled(size: CGFloat, weight: Font.Weight, design: Font.Design = .default, scale: CGFloat) -> Font {
        Font.system(size: round(size * scale), weight: weight, design: design)
    }
}
