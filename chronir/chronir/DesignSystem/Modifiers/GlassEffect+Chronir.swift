import SwiftUI

extension View {
    /// Rounded-rect glass button — tinted when a color is provided, plain otherwise.
    func chronirGlassButton(tint: Color? = nil) -> some View {
        let glass = tint.map { GlassTokens.element.tint($0).interactive() }
            ?? GlassTokens.element.interactive()
        return self.glassEffect(glass, in: .rect(cornerRadius: RadiusTokens.sm))
    }

    /// Untinted glass capsule (e.g. unselected chips).
    func chronirGlassCapsule() -> some View {
        self.glassEffect(GlassTokens.element, in: .capsule)
    }

    /// Tinted glass capsule (e.g. selected filter chips).
    func chronirGlassTintedCapsule(tint: Color) -> some View {
        self.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .capsule)
    }

    /// Tinted glass circle (e.g. FAB, selected day pickers).
    func chronirGlassTintedCircle(tint: Color) -> some View {
        self.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .circle)
    }

    /// Untinted glass circle (e.g. unselected day pickers).
    func chronirGlassCircle() -> some View {
        self.glassEffect(GlassTokens.element, in: .circle)
    }
}
