package com.chronir.designsystem.tokens

// Values sourced from design-tokens/tokens/animation.json (Style Dictionary)
// See docs/design-system.md Section 3.6 for full spec

object AnimationTokens {
    // MARK: - Durations (milliseconds)

    const val DurationInstant = 100
    const val DurationFast = 150
    const val DurationStandard = 300
    const val DurationSlow = 500

    // MARK: - Spring

    const val SpringDampingRatio = 0.8f
    const val SpringStiffness = 400f

    const val BouncySpringDampingRatio = 0.65f
    const val BouncySpringStiffness = 300f

    // Backward compat aliases
    const val DurationMedium = DurationStandard
    const val DurationVerySlow = 700
}
