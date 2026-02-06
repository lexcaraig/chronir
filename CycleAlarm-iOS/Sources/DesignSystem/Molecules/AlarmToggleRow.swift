import SwiftUI

struct AlarmToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                CycleText(title, font: TypographyTokens.titleSmall)
                CycleText(subtitle, font: TypographyTokens.bodySmall, color: ColorTokens.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isEnabled)
                .tint(ColorTokens.primary)
                .labelsHidden()
        }
        .padding(SpacingTokens.md)
    }
}

#Preview {
    @Previewable @State var isEnabled = true
    AlarmToggleRow(
        title: "Morning Workout",
        subtitle: "Every Monday at 6:30 AM",
        isEnabled: $isEnabled
    )
    .background(ColorTokens.surfaceCard)
}
