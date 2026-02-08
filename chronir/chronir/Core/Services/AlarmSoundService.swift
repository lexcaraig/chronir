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

    static let availableSounds: [(name: String, displayName: String)] = [
        ("alarm", "Alarm"),
        ("Tritone", "Tritone"),
        ("tweet_sent", "Tweet"),
        ("sms-received1", "Note"),
        ("sms-received5", "Pulse"),
        ("New/Anticipate", "Anticipate")
    ]

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
        if let bundledURL = Bundle.main.url(forResource: name, withExtension: "caf") {
            return bundledURL
        }

        let systemPath = "/System/Library/Audio/UISounds/\(name).caf"
        if FileManager.default.fileExists(atPath: systemPath) {
            return URL(fileURLWithPath: systemPath)
        }

        // Fallback to default alarm sound
        let fallbackPath = "/System/Library/Audio/UISounds/alarm.caf"
        if name != "alarm", FileManager.default.fileExists(atPath: fallbackPath) {
            return URL(fileURLWithPath: fallbackPath)
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
