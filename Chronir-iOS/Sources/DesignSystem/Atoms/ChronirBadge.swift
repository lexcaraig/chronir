import SwiftUI

struct ChronirBadge: View {
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
        ChronirBadge("Weekly")
        ChronirBadge("Monthly", color: ColorTokens.secondary)
        ChronirBadge("Active", color: ColorTokens.success)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
