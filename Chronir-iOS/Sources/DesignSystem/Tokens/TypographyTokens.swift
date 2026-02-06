import SwiftUI

enum TypographyTokens {
    // MARK: - Display
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 45, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: - Headline
    static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .rounded)

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
}
