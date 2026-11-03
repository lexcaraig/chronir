import SwiftUI

enum ChronirButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

struct ChronirButton: View {
    let title: String
    let style: ChronirButtonStyle
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    init(
        _ title: String,
        style: ChronirButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(role: style == .destructive ? .destructive : nil, action: action) {
            ZStack {
                Text(title)
                    .chronirFont(.labelLarge)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget)
            .padding(.vertical, SpacingTokens.xxs)
            .padding(.horizontal, SpacingTokens.lg)
            .modifier(ChronirButtonBackground(style: style))
            .opacity(isEnabled ? 1 : 0.4)
            .contentShape(.rect(cornerRadius: RadiusTokens.sm))
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? "Loading" : "")
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return ColorTokens.onPrimary
        case .secondary: return ColorTokens.textPrimary
        case .destructive: return ColorTokens.badgeErrorForeground
        case .ghost: return ColorTokens.primary
        }
    }
}

private struct ChronirButtonBackground: ViewModifier {
    let style: ChronirButtonStyle

    func body(content: Content) -> some View {
        switch style {
        case .primary:
            content.chronirGlassButton(tint: ColorTokens.primary)
        case .secondary:
            content.chronirGlassButton()
        case .destructive:
            // badgeErrorBackground (#DC2626) keeps white text at 4.83:1; `error` (#EF4444) is only 3.76:1.
            content.chronirGlassButton(tint: ColorTokens.badgeErrorBackground)
        case .ghost:
            content
        }
    }
}

private struct ChronirButtonGallery: View {
    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            ChronirButton("Primary Action") {}
            ChronirButton("Secondary", style: .secondary) {}
            ChronirButton("Delete", style: .destructive) {}
            ChronirButton("Ghost Action", style: .ghost) {}
            ChronirButton("Loading", isLoading: true) {}
            ChronirButton("Disabled") {}
                .disabled(true)
        }
        .padding()
    }
}

#Preview("Light") {
    ChronirButtonGallery()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { ChronirButtonGallery() }
}

#Preview("Liquid Glass") {
    GlassPreview { ChronirButtonGallery() }
}
