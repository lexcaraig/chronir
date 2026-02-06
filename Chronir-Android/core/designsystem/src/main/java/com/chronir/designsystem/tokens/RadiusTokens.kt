package com.chronir.designsystem.tokens

import androidx.compose.ui.unit.dp

// Values sourced from design-tokens/tokens/radius.json (Style Dictionary)
// See docs/design-system.md Section 3.5 for full spec

object RadiusTokens {
    val Sm = 8.dp
    val Md = 12.dp
    val Lg = 16.dp
    val Xl = 28.dp
    val Sheet = 34.dp
    val Full = 9999.dp

    // Backward compat aliases
    val None = 0.dp
    val Small = Sm
    val Medium = Sm
    val Default = Md
    val Large = Lg
    val XLarge = Xl
}
