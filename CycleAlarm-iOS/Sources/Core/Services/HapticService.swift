import Foundation

#if canImport(UIKit)
import UIKit

protocol HapticServiceProtocol {
    func playSuccess()
    func playError()
    func playSelection()
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle)
}

final class HapticService: HapticServiceProtocol {
    static let shared = HapticService()

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
}

#else

protocol HapticServiceProtocol {
    func playSuccess()
    func playError()
    func playSelection()
}

final class HapticService: HapticServiceProtocol {
    static let shared = HapticService()

    private init() {}

    func playSuccess() {}
    func playError() {}
    func playSelection() {}
}

#endif
