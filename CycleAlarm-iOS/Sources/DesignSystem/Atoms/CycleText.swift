import SwiftUI

struct CycleText: View {
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
        CycleText("Display", font: TypographyTokens.displayLarge)
        CycleText("Headline", font: TypographyTokens.headlineMedium)
        CycleText("Body", font: TypographyTokens.bodyMedium)
        CycleText("Label", font: TypographyTokens.labelMedium, color: ColorTokens.textSecondary)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
