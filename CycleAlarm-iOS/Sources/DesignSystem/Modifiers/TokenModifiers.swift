import SwiftUI

// MARK: - Card Style Modifier

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(SpacingTokens.lg)
            .background(ColorTokens.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
    }
}

// MARK: - Surface Style Modifier

struct SurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(SpacingTokens.md)
            .background(ColorTokens.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func surfaceStyle() -> some View {
        modifier(SurfaceModifier())
    }
}
