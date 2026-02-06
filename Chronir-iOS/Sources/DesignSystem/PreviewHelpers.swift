import SwiftUI

/// Dark-mode preview wrapper. Use in `#Preview` to get a dark background.
struct DarkPreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .preferredColorScheme(.dark)
            .background(ColorTokens.backgroundPrimary)
    }
}

/// Wraps content in both light and dark mode side by side.
struct ThemePreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 0) {
            content
                .preferredColorScheme(.light)
                .frame(maxWidth: .infinity)

            content
                .preferredColorScheme(.dark)
                .frame(maxWidth: .infinity)
                .background(ColorTokens.backgroundPrimary)
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
        VStack(spacing: SpacingTokens.md) {
            content
                .environment(\.dynamicTypeSize, .xSmall)
            content
                .environment(\.dynamicTypeSize, .large)
            content
                .environment(\.dynamicTypeSize, .xxxLarge)
        }
        .padding()
        .background(ColorTokens.backgroundPrimary)
    }
}

/// Wraps content for component state matrix (useful for buttons, toggles, etc.)
struct StateMatrixPreview<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .padding()
        }
        .background(ColorTokens.backgroundPrimary)
    }
}
