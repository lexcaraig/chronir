import SwiftUI

struct CycleToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            CycleText(label, font: TypographyTokens.bodyMedium)
        }
        .tint(ColorTokens.primary)
    }
}

#Preview {
    @Previewable @State var isOn = true
    CycleToggle(label: "Enable Alarm", isOn: $isOn)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
