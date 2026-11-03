package com.chronir.designsystem.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback

/**
 * The user's "Haptic Feedback" setting. Provided by each activity from `SettingsRepository`;
 * every design-system haptic goes through [chronirHapticFeedback] so it honors this.
 */
val LocalChronirHapticsEnabled = staticCompositionLocalOf { true }

private object NoHapticFeedback : HapticFeedback {
    override fun performHapticFeedback(hapticFeedbackType: HapticFeedbackType) = Unit
}

/** The platform haptics when the user has them on, otherwise a no-op. */
@Composable
@ReadOnlyComposable
fun chronirHapticFeedback(): HapticFeedback =
    if (LocalChronirHapticsEnabled.current) LocalHapticFeedback.current else NoHapticFeedback
