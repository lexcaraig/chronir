import SwiftUI

enum CycleButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

struct CycleButton: View {
    let title: String
    let style: CycleButtonStyle
    let action: () -> Void

    init(
        _ title: String,
        style: CycleButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TypographyTokens.labelLarge)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpacingTokens.md)
                .padding(.horizontal, SpacingTokens.lg)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return ColorTokens.primary
        case .secondary: return ColorTokens.backgroundTertiary
        case .destructive: return ColorTokens.error
        case .ghost: return .clear
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

#Preview {
    VStack(spacing: SpacingTokens.md) {
        CycleButton("Primary Action") {}
        CycleButton("Secondary", style: .secondary) {}
        CycleButton("Delete", style: .destructive) {}
        CycleButton("Ghost Action", style: .ghost) {}
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
