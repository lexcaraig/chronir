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
    let action: () -> Void

    init(
        _ title: String,
        style: ChronirButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .chronirFont(.labelLarge)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpacingTokens.md)
                .padding(.horizontal, SpacingTokens.lg)
                .modifier(GlassButtonModifier(style: style))
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return ColorTokens.textPrimary
        case .destructive: return .white
        case .ghost: return ColorTokens.primary
        }
    }
}

private struct GlassButtonModifier: ViewModifier {
    let style: ChronirButtonStyle

    func body(content: Content) -> some View {
        switch style {
        case .primary:
            content.chronirGlassButton(tint: ColorTokens.primary)
        case .secondary:
            content.chronirGlassButton()
        case .destructive:
            content.chronirGlassButton(tint: ColorTokens.error)
        case .ghost:
            content
        }
    }
}

#Preview("Button Variants") {
    VStack(spacing: SpacingTokens.md) {
        ChronirButton("Primary Action") {}
        ChronirButton("Secondary", style: .secondary) {}
        ChronirButton("Delete", style: .destructive) {}
        ChronirButton("Ghost Action", style: .ghost) {}
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
