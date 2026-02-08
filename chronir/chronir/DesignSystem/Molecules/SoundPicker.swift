import SwiftUI

struct SoundPicker: View {
    @Bindable private var settings = UserSettings.shared
    private let soundService = AlarmSoundService.shared

    var body: some View {
        List {
            ForEach(AlarmSoundService.availableSounds, id: \.name) { sound in
                Button {
                    settings.selectedAlarmSound = sound.name
                    soundService.previewSound(sound.name)
                } label: {
                    HStack {
                        ChronirText(sound.displayName, style: .bodyPrimary)
                        Spacer()
                        if settings.selectedAlarmSound == sound.name {
                            ChronirIcon(
                                systemName: "checkmark",
                                size: .small,
                                color: ColorTokens.primary
                            )
                        }
                    }
                }
                .listRowBackground(ColorTokens.surfaceCard)
            }
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Alarm Sound")
        .onDisappear {
            soundService.stopPlaying()
        }
    }
}

#Preview {
    NavigationStack {
        SoundPicker()
    }
}
