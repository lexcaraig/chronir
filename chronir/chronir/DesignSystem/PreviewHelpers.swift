import SwiftUI

/// Dark-mode preview wrapper. Use in `#Preview` to get a dark background.
struct DarkPreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(ColorTokens.backgroundPrimary)
            .environment(\.colorScheme, .dark)
            .environment(\.chronirTheme, .dark)
    }
}

/// Wraps content in both light and dark mode side by side.
/// Uses `.environment(\.colorScheme)` per half — `.preferredColorScheme` is window-wide,
/// so two conflicting values would render both halves in the same scheme.
struct ThemePreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity)
                .padding()
                .background(ColorTokens.backgroundPrimary)
                .environment(\.colorScheme, .light)
                .environment(\.chronirTheme, .light)

            content
                .frame(maxWidth: .infinity)
                .padding()
                .background(ColorTokens.backgroundPrimary)
                .environment(\.colorScheme, .dark)
                .environment(\.chronirTheme, .dark)
        }
    }
}

/// Wraps content at multiple Dynamic Type sizes for accessibility testing.
struct DynamicTypePreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.md) {
                content
                    .environment(\.dynamicTypeSize, .xSmall)
                content
                    .environment(\.dynamicTypeSize, .large)
                content
                    .environment(\.dynamicTypeSize, .xxxLarge)
                content
                    .environment(\.dynamicTypeSize, .accessibility3)
            }
            .padding()
        }
        .background(ColorTokens.backgroundPrimary)
    }
}

/// Liquid Glass preview: activates the glass theme (`\.chronirTheme = .liquidGlass`) so every
/// theme-aware glass modifier renders glass, over the default glass gradient in the dark scheme.
struct GlassPreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AdaptiveGlassContainer {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.backgroundGradient.ignoresSafeArea())
        .environment(\.chronirTheme, .liquidGlass)
        .environment(\.colorScheme, .dark)
    }
}
