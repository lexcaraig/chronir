import SwiftUI

struct ChronirToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            ChronirText(label, font: TypographyTokens.bodyMedium)
        }
        .tint(ColorTokens.primary)
    }
}

#Preview {
    @Previewable @State var isOn = true
    ChronirToggle(label: "Enable Alarm", isOn: $isOn)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
