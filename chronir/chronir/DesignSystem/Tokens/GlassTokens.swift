import SwiftUI

// iOS Liquid Glass tokens — iOS 26+ only
// See docs/design-system.md Section 3.7 and Section 7.1 for full spec
//
// DO apply glass: toolbars, floating buttons, modal overlays, navigation chrome, alarm cards
// DON'T apply glass: list rows, firing screen

enum GlassTokens {
    // MARK: - Glass Radii

    /// Glass card corners (28pt) — used for glass-styled card surfaces
    static let cardRadius: CGFloat = 28

    /// Glass sheet corners (34pt) — used for glass-styled modal sheets
    static let sheetRadius: CGFloat = 34

    // MARK: - Glass Variants

    /// Navigation bars, tab bars, toolbar chrome
    static let chrome = Glass.regular

    /// Floating panels, popovers, modal overlays
    static let surface = Glass.regular

    /// Buttons, chips, text fields, interactive controls
    static let element = Glass.regular

    /// Alarm cards — frosted glass over wallpaper or dark background
    static let card = Glass.regular
}
