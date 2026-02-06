import SwiftUI

struct SnoozeOptionButton: View {
    let minutes: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: SpacingTokens.xs) {
                CycleText("\(minutes)", font: TypographyTokens.headlineSmall)
                CycleText("min", font: TypographyTokens.labelSmall, color: ColorTokens.textSecondary)
            }
            .frame(width: 64, height: 64)
            .background(ColorTokens.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
        }
    }
}

#Preview {
    HStack(spacing: SpacingTokens.md) {
        SnoozeOptionButton(minutes: 5) {}
        SnoozeOptionButton(minutes: 10) {}
        SnoozeOptionButton(minutes: 15) {}
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
