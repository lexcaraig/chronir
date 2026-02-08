import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChronirToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            ChronirText(label, style: .bodyMedium)
        }
        .tint(ColorTokens.primary)
        .onChange(of: isOn) {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
}

#Preview("Toggle States") {
    @Previewable @State var isOn = true
    @Previewable @State var isOff = false
    VStack(spacing: SpacingTokens.md) {
        ChronirToggle(label: "Enable Alarm", isOn: $isOn)
        ChronirToggle(label: "Persistent Mode", isOn: $isOff)
    }
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
