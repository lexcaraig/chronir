import SwiftUI

struct ChronirToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: userChange) {
            ChronirText(label, style: .bodyPrimary)
        }
        .tint(ColorTokens.toggleOn)
    }

    /// Plays haptics only for user-initiated flips (not programmatic changes to `isOn`),
    /// and only when the user's Haptic Feedback setting is on.
    private var userChange: Binding<Bool> {
        Binding(
            get: { isOn },
            set: { newValue in
                isOn = newValue
                #if os(iOS)
                if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
                #endif
            }
        )
    }
}

private struct ChronirToggleGallery: View {
    @State private var isOn = true
    @State private var isOff = false

    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            ChronirToggle(label: "Enable Alarm", isOn: $isOn)
            ChronirToggle(label: "Persistent Mode", isOn: $isOff)
        }
        .padding()
    }
}

#Preview("Light") {
    ChronirToggleGallery()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { ChronirToggleGallery() }
}
