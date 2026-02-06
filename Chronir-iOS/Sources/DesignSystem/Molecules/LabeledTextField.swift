import SwiftUI

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText(label, font: TypographyTokens.labelMedium, color: ColorTokens.textSecondary)
            TextField(placeholder, text: $text)
                .font(TypographyTokens.bodyMedium)
                .foregroundStyle(ColorTokens.textPrimary)
                .padding(SpacingTokens.md)
                .background(ColorTokens.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $text)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
