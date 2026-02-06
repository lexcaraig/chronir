import SwiftUI

struct ChronirIcon: View {
    let systemName: String
    var size: CGFloat
    var color: Color

    init(
        systemName: String,
        size: CGFloat = 24,
        color: Color = ColorTokens.textPrimary
    ) {
        self.systemName = systemName
        self.size = size
        self.color = color
    }

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

#Preview {
    HStack(spacing: SpacingTokens.lg) {
        ChronirIcon(systemName: "alarm.fill", color: ColorTokens.primary)
        ChronirIcon(systemName: "bell.fill", size: 32, color: ColorTokens.warning)
        ChronirIcon(systemName: "checkmark.circle.fill", size: 16, color: ColorTokens.success)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
