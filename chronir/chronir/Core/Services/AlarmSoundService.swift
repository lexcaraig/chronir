import Foundation
import AVFoundation

protocol AlarmSoundServiceProtocol {
    func startPlaying()
    func stopPlaying()
}

#if os(iOS)
final class AlarmSoundService: AlarmSoundServiceProtocol {
    static let shared = AlarmSoundService()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func startPlaying() {
        configureAudioSession()

        guard let url = findAlarmSoundURL() else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            AudioServicesPlayAlertSound(SystemSoundID(1005))
        }
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

    private func findAlarmSoundURL() -> URL? {
        if let bundledURL = Bundle.main.url(forResource: "alarm", withExtension: "caf") {
            return bundledURL
        }

        let systemPath = "/System/Library/Audio/UISounds/alarm.caf"
        if FileManager.default.fileExists(atPath: systemPath) {
            return URL(fileURLWithPath: systemPath)
        }

        let tritonePath = "/System/Library/Audio/UISounds/Tritone.caf"
        if FileManager.default.fileExists(atPath: tritonePath) {
            return URL(fileURLWithPath: tritonePath)
        }

        return nil
    }
}
#else
final class AlarmSoundService: AlarmSoundServiceProtocol {
    static let shared = AlarmSoundService()
    private init() {}
    func startPlaying() {}
    func stopPlaying() {}
}
#endif
