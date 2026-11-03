import SwiftUI

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String?
    var maxLength: Int?
    var softWarningLength: Int?

    private var showsSoftWarning: Bool {
        error == nil && softWarningLength.map { text.count > $0 } == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            HStack {
                ChronirText(label, style: .labelMedium, color: ColorTokens.textSecondary)
                    .accessibilityHidden(true) // spoken as the field's label below
                if let maxLength {
                    Spacer()
                    ChronirText(
                        "\(text.count)/\(maxLength)",
                        style: .labelSmall,
                        color: text.count >= maxLength ? ColorTokens.textError : ColorTokens.textSecondary
                    )
                    .accessibilityLabel("\(text.count) of \(maxLength) characters")
                }
            }
            TextField(label, text: $text, prompt: Text(placeholder).foregroundStyle(ColorTokens.textSecondary))
                // With a prompt, iOS exposes only the placeholder; VoiceOver needs the field's name too.
                .accessibilityLabel(label)
                .chronirFont(.bodyMedium)
                .foregroundStyle(ColorTokens.textPrimary)
                .padding(SpacingTokens.md)
                .background(ColorTokens.backgroundPrimary, in: .rect(cornerRadius: RadiusTokens.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: RadiusTokens.sm)
                        .stroke(
                            error != nil ? ColorTokens.textError : ColorTokens.borderDefault,
                            lineWidth: error != nil ? SpacingTokens.hairline * 3 : SpacingTokens.hairline
                        )
                )
                .accessibilityHint(error ?? "")
                .onChange(of: text) {
                    if let maxLength, text.count > maxLength {
                        text = String(text.prefix(maxLength))
                    }
                }
            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .chronirFont(.labelSmall)
                    .foregroundStyle(ColorTokens.textError)
            } else if showsSoftWarning {
                ChronirText("May be truncated on lock screen", style: .labelSmall, color: ColorTokens.textWarning)
            }
        }
        .onChange(of: error) { _, newError in
            if let newError {
                AccessibilityNotification.Announcement(newError).post()
            }
        }
    }
}

private struct LabeledTextFieldGallery: View {
    @State private var text = ""
    @State private var longText = "Renew passport at the downtown office"

    var body: some View {
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
                text: $longText,
                maxLength: 60,
                softWarningLength: 32
            )
        }
        .padding()
    }
}

#Preview("Light") {
    LabeledTextFieldGallery()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { LabeledTextFieldGallery() }
}
