import SwiftUI

// iOS Liquid Glass tokens — iOS 26+ only
// See docs/design-system.md Section 3.7 and Section 7.1 for full spec
//
// DO apply glass: toolbars, floating buttons, modal overlays, navigation chrome
// DON'T apply glass: alarm cards, list rows, firing screen

enum GlassTokens {
    // MARK: - Glass Radii

    /// Glass card corners (28pt) — used for glass-styled card surfaces
    static let cardRadius: CGFloat = 28

    /// Glass sheet corners (34pt) — used for glass-styled modal sheets
    static let sheetRadius: CGFloat = 34
}
