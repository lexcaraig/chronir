import SwiftUI

enum AnimationTokens {
    /// Quick interactions (toggles, selections) - 150ms
    static let fast: Animation = .easeInOut(duration: 0.15)

    /// Standard transitions (cards, expansions) - 250ms
    static let standard: Animation = .easeInOut(duration: 0.25)

    /// Elaborate animations (page transitions, modals) - 350ms
    static let slow: Animation = .easeInOut(duration: 0.35)

    /// Spring animation for bouncy interactions
    static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.7)

    /// Gentle spring for subtle bounces
    static let gentleSpring: Animation = .spring(response: 0.5, dampingFraction: 0.8)

    // MARK: - Durations (for non-Animation contexts)

    /// 150ms
    static let fastDuration: Double = 0.15
    /// 250ms
    static let standardDuration: Double = 0.25
    /// 350ms
    static let slowDuration: Double = 0.35
}
