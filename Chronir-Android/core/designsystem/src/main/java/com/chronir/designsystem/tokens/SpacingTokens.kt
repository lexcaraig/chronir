package com.chronir.designsystem.tokens

import androidx.compose.ui.unit.dp

// Values sourced from design-tokens/tokens/spacing.json (Style Dictionary)
// See docs/design-system.md Section 3.4 for full spec

object SpacingTokens {
    // MARK: - Scale

    val XXSmall = 4.dp
    val XSmall = 8.dp
    val Small = 12.dp
    val Medium = 16.dp
    val Large = 24.dp
    val XLarge = 32.dp
    val XXLarge = 48.dp
    val XXXLarge = 48.dp // alias for backward compat

    // MARK: - Functional

    val CardPadding = 16.dp
    val ListGap = 12.dp
    val TouchMinTarget = 44.dp
    val FiringButtonZone = 60.dp // percentage of screen height

    // Backward compat aliases
    val None = 0.dp
    val Default = Medium
    val Huge = XXLarge
    val Massive = 64.dp
}
