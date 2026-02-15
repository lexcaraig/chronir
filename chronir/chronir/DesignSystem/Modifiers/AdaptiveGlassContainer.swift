import SwiftUI

/// Wraps `GlassEffectContainer` conditionally — passthrough in Light/Dark themes.
struct AdaptiveGlassContainer<Content: View>: View {
    @Environment(\.chronirTheme) private var theme
    @ViewBuilder let content: () -> Content

    var body: some View {
        if theme.isGlassActive {
            GlassEffectContainer { content() }
        } else {
            content()
        }
    }
}
