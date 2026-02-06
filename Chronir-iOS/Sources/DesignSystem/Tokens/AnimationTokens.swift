import SwiftUI

// Values sourced from design-tokens/tokens/animation.json (Style Dictionary)
// See docs/design-system.md Section 3.6 for full spec

enum AnimationTokens {
    // MARK: - Durations

    static let instant: Animation = .easeInOut(duration: 0.1)
    static let fast: Animation = .easeInOut(duration: 0.15)
    static let standard: Animation = .easeInOut(duration: 0.3)
    static let slow: Animation = .easeInOut(duration: 0.5)

    // MARK: - Springs

    static let spring: Animation = .spring(
        response: 0.35,
        dampingFraction: 0.8
    )
    static let gentleSpring = spring  // alias for backward compat

    static let bouncySpring: Animation = .spring(
        response: 0.4,
        dampingFraction: 0.65
    )

    // MARK: - Raw Durations (for non-Animation contexts)

    static let instantDuration: Double = 0.1
    static let fastDuration: Double = 0.15
    static let standardDuration: Double = 0.3
    static let slowDuration: Double = 0.5
}
