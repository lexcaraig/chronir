import SwiftUI

struct SoundPicker: View {
    @Binding var selectedSound: String
    var isPlusTier: Bool = false
    var showPaywall: (() -> Void)?
    private let soundService = AlarmSoundService.shared

    var body: some View {
        List {
            ForEach(AlarmSoundService.allSounds) { sound in
                Button {
                    if sound.requiresPlus && !isPlusTier {
                        showPaywall?()
                    } else {
                        selectedSound = sound.name
                        soundService.previewSound(sound.name)
                    }
                } label: {
                    HStack(spacing: SpacingTokens.md) {
                        Image(systemName: sound.iconName)
                            .font(.system(size: 14))
                            .foregroundStyle(sound.requiresPlus && !isPlusTier
                                ? ColorTokens.textTertiary
                                : ColorTokens.primary)
                            .frame(width: 28)

                        ChronirText(
                            sound.displayName,
                            style: .bodyPrimary,
                            color: sound.requiresPlus && !isPlusTier
                                ? ColorTokens.textTertiary
                                : ColorTokens.textPrimary
                        )

                        if sound.requiresPlus && !isPlusTier {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(ColorTokens.textTertiary)
                        }

                        Spacer()

                        if selectedSound == sound.name {
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

/// Settings-level default sound picker (wraps the shared picker for UserSettings)
struct DefaultSoundPicker: View {
    @Bindable private var settings = UserSettings.shared

    var body: some View {
        SoundPicker(
            selectedSound: $settings.selectedAlarmSound,
            isPlusTier: SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
        )
    }
}

#Preview {
    NavigationStack {
        SoundPicker(selectedSound: .constant("alarm"), isPlusTier: true)
    }
}
