import Foundation

#if canImport(UIKit)
import UIKit

protocol HapticServiceProtocol {
    func playSuccess()
    func playError()
    func playSelection()
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    func playAlarmVibration()
    func startAlarmVibrationLoop()
    func stopAlarmVibrationLoop()
}

final class HapticService: HapticServiceProtocol {
    static let shared = HapticService()

    private var vibrationTimer: Timer?

    private init() {}

    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func playAlarmVibration() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func startAlarmVibrationLoop() {
        stopAlarmVibrationLoop()
        playAlarmVibration()
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.playAlarmVibration()
        }
    }

    func stopAlarmVibrationLoop() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}

#else

protocol HapticServiceProtocol {
    func playSuccess()
    func playError()
    func playSelection()
    func playAlarmVibration()
    func startAlarmVibrationLoop()
    func stopAlarmVibrationLoop()
}

final class HapticService: HapticServiceProtocol {
    static let shared = HapticService()

    private init() {}

    func playSuccess() {}
    func playError() {}
    func playSelection() {}
    func playAlarmVibration() {}
    func startAlarmVibrationLoop() {}
    func stopAlarmVibrationLoop() {}
}

#endif
