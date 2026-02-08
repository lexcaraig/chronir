import Foundation

// Values sourced from design-tokens/tokens/spacing.json (Style Dictionary)
// See docs/design-system.md Section 3.4 for full spec

enum SpacingTokens {
    // MARK: - Scale

    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 48  // alias for backward compat

    // MARK: - Functional

    static let cardPadding: CGFloat = 16
    static let listGap: CGFloat = 12
    static let touchMinTarget: CGFloat = 44
    static let firingButtonZone: CGFloat = 60  // percentage of screen height
}
