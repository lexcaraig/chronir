import SwiftUI

// iOS Liquid Glass tokens — iOS 26+ only
// See docs/design-system.md Section 3.7 and Section 7.1 for full spec
//
// DO apply glass: toolbars, floating buttons, chips, modal overlays, navigation chrome (the control layer)
// DON'T apply glass: content cards (alarm / category cards use surfaceCard or a system material),
// list rows, the firing screen

enum GlassTokens {
    // MARK: - Glass Radii

    /// Card corners (28pt) — content cards; glass-styled control surfaces
    static let cardRadius: CGFloat = RadiusTokens.xl

    /// Sheet corners (34pt) — glass-styled modal sheets
    static let sheetRadius: CGFloat = RadiusTokens.sheet

    // MARK: - Glass Variants

    /// Navigation bars, tab bars, toolbar chrome
    static let chrome = Glass.regular

    /// Floating panels, popovers, modal overlays
    static let surface = Glass.regular

    /// Buttons, chips, text fields, interactive controls
    static let element = Glass.regular

    /// Floating card-shaped controls. Not for content cards (see `chronirGlassCard()`).
    static let card = Glass.regular
}
