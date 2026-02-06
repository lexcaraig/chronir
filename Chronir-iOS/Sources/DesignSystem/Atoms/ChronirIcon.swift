import SwiftUI

enum ChronirIconSize {
    case small   // 16pt
    case medium  // 24pt (default)
    case large   // 32pt

    var points: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 24
        case .large: return 32
        }
    }
}

struct ChronirIcon: View {
    let systemName: String
    var size: ChronirIconSize
    var color: Color

    init(
        systemName: String,
        size: ChronirIconSize = .medium,
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
            .frame(width: size.points, height: size.points)
            .foregroundStyle(color)
    }
}

#Preview("Icon Sizes") {
    HStack(spacing: SpacingTokens.lg) {
        ChronirIcon(systemName: "alarm.fill", size: .small, color: ColorTokens.textSecondary)
        ChronirIcon(systemName: "alarm.fill", size: .medium, color: ColorTokens.primary)
        ChronirIcon(systemName: "alarm.fill", size: .large, color: ColorTokens.warning)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Icon Colors") {
    HStack(spacing: SpacingTokens.lg) {
        ChronirIcon(systemName: "bell.fill", color: ColorTokens.primary)
        ChronirIcon(systemName: "checkmark.circle.fill", color: ColorTokens.success)
        ChronirIcon(systemName: "exclamationmark.triangle.fill", color: ColorTokens.warning)
        ChronirIcon(systemName: "xmark.circle.fill", color: ColorTokens.error)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
