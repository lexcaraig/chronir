import SwiftUI

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String?
    var maxLength: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            HStack {
                ChronirText(label, style: .labelMedium, color: ColorTokens.textSecondary)
                if let maxLength {
                    Spacer()
                    ChronirText(
                        "\(text.count)/\(maxLength)",
                        style: .labelSmall,
                        color: text.count >= maxLength ? ColorTokens.error : ColorTokens.textSecondary
                    )
                }
            }
            TextField(placeholder, text: $text)
                .chronirFont(.bodyMedium)
                .foregroundStyle(ColorTokens.textPrimary)
                .padding(SpacingTokens.md)
                .chronirGlassButton()
                .overlay(
                    RoundedRectangle(cornerRadius: RadiusTokens.sm)
                        .stroke(error != nil ? ColorTokens.error : .clear, lineWidth: 1.5)
                )
                .onChange(of: text) {
                    if let maxLength, text.count > maxLength {
                        text = String(text.prefix(maxLength))
                    }
                }
            if let error {
                ChronirText(error, style: .labelSmall, color: ColorTokens.error)
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack(spacing: SpacingTokens.lg) {
        LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $text)
        LabeledTextField(
            label: "With Error",
            placeholder: "Enter a name...",
            text: $text,
            error: "Alarm name is required."
        )
        LabeledTextField(
            label: "With Max Length",
            placeholder: "Enter a name...",
            text: $text,
            maxLength: 60
        )
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
