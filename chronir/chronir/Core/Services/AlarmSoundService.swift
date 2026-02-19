import Foundation
import AVFoundation

protocol AlarmSoundServiceProtocol {
    func startPlaying(soundName: String?)
    func stopPlaying()
    func previewSound(_ name: String)
}

#if os(iOS)
final class AlarmSoundService: AlarmSoundServiceProtocol {
    static let shared = AlarmSoundService()

    struct SoundOption: Identifiable {
        let name: String
        let displayName: String
        let iconName: String
        let requiresPlus: Bool
        var id: String { name }
    }

    static let allSounds: [SoundOption] = [
        SoundOption(name: "alarm", displayName: "Classic Alarm", iconName: "alarm.fill", requiresPlus: false),
        SoundOption(name: "Tritone", displayName: "Gentle Chime", iconName: "bell.fill", requiresPlus: false),
        SoundOption(name: "sms-received5", displayName: "Digital Pulse", iconName: "waveform", requiresPlus: true),
        SoundOption(name: "sms-received1", displayName: "Soft Note", iconName: "music.note", requiresPlus: true),
        SoundOption(name: "tweet_sent", displayName: "Quick Alert", iconName: "bolt.fill", requiresPlus: true),
        SoundOption(name: "anticipate", displayName: "Anticipate", iconName: "sparkles", requiresPlus: true)
    ]

    /// Backward-compatible accessor
    static var availableSounds: [(name: String, displayName: String)] {
        allSounds.map { ($0.name, $0.displayName) }
    }

    static var freeSounds: [SoundOption] {
        allSounds.filter { !$0.requiresPlus }
    }

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func startPlaying(soundName: String? = nil) {
        configureAudioSession()

        let name = soundName ?? UserSettings.shared.selectedAlarmSound
        guard let url = findSoundURL(name: name) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            AudioServicesPlayAlertSound(SystemSoundID(1005))
        }
    }

    func previewSound(_ name: String) {
        stopPlaying()
        configureAudioSession()

        guard let url = findSoundURL(name: name) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.play()
        } catch {}
    }

    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        deactivateAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [.duckOthers])
            try session.setActive(true)
        } catch {}
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {}
    }

    private func findSoundURL(name: String) -> URL? {
        // Check app bundle first (all sounds should be bundled)
        if let bundledURL = Bundle.main.url(forResource: name, withExtension: "caf") {
            return bundledURL
        }

        // Fallback to bundled default alarm sound
        if name != "alarm",
           let fallback = Bundle.main.url(forResource: "alarm", withExtension: "caf") {
            return fallback
        }

        return nil
    }
}
#else
final class AlarmSoundService: AlarmSoundServiceProtocol {
    static let shared = AlarmSoundService()
    private init() {}
    func startPlaying(soundName: String? = nil) {}
    func stopPlaying() {}
    func previewSound(_ name: String) {}
}
#endif
