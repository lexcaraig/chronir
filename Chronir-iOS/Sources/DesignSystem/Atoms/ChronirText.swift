import SwiftUI

struct ChronirText: View {
    let text: String
    var font: Font
    var color: Color

    init(
        _ text: String,
        font: Font = TypographyTokens.bodyMedium,
        color: Color = ColorTokens.textPrimary
    ) {
        self.text = text
        self.font = font
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: SpacingTokens.md) {
        ChronirText("Display", font: TypographyTokens.displayLarge)
        ChronirText("Headline", font: TypographyTokens.headlineMedium)
        ChronirText("Body", font: TypographyTokens.bodyMedium)
        ChronirText("Label", font: TypographyTokens.labelMedium, color: ColorTokens.textSecondary)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
