import SwiftUI

struct CycleBadge: View {
    let text: String
    var color: Color

    init(_ text: String, color: Color = ColorTokens.primary) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(TypographyTokens.labelSmall)
            .foregroundStyle(.white)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xs)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: SpacingTokens.sm) {
        CycleBadge("Weekly")
        CycleBadge("Monthly", color: ColorTokens.secondary)
        CycleBadge("Active", color: ColorTokens.success)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
