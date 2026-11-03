package com.chronir.designsystem.molecules

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.chronirHapticFeedback
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import kotlinx.coroutines.launch

private val HoldRingBaseSize = 120.dp // token-exempt: firing-spec hold ring, scaled by fontScale below
private val HoldRingStroke = 6.dp // token-exempt: firing-spec hold ring stroke

/**
 * Press-and-hold ring for persistent alarms. Holding for [holdDurationMs] calls [onComplete].
 *
 * Accessibility: exposed as a Button whose activation ([accessibilityActionLabel]) completes
 * immediately, so TalkBack, Switch Access and keyboard users have an alternative to the hold gesture
 * (WCAG 2.5.1 / 2.1.1). Haptic ticks mark the start and the completion of the hold.
 */
@Composable
fun HoldToCompleteButton(
    onComplete: () -> Unit,
    modifier: Modifier = Modifier,
    holdDurationMs: Long = 3000L,
    label: String = "Hold to Complete",
    accessibilityActionLabel: String = "Complete",
    progressColor: Color = MaterialTheme.colorScheme.primary,
    trackColor: Color = MaterialTheme.colorScheme.surfaceVariant,
    contentColor: Color = MaterialTheme.colorScheme.onSurface
) {
    val progress = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()
    val haptic = chronirHapticFeedback()
    // Grow the ring with font scale (capped) so the label still fits at 200% text.
    val ringSize = HoldRingBaseSize * LocalDensity.current.fontScale.coerceIn(1f, 1.6f)

    Box(
        modifier = modifier
            .size(ringSize)
            .semantics {
                role = Role.Button
                contentDescription = label
                onClick(label = accessibilityActionLabel) {
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    onComplete()
                    true
                }
            }
            .pointerInput(haptic) {
                detectTapGestures(
                    onPress = {
                        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        scope.launch {
                            progress.animateTo(
                                targetValue = 1f,
                                animationSpec = tween(
                                    durationMillis = holdDurationMs.toInt(),
                                    easing = LinearEasing
                                )
                            )
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            onComplete()
                        }
                        tryAwaitRelease()
                        scope.launch {
                            if (progress.value < 1f) {
                                progress.snapTo(0f)
                            }
                        }
                    }
                )
            },
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator(
            progress = { progress.value },
            modifier = Modifier.size(ringSize),
            color = progressColor,
            trackColor = trackColor,
            strokeWidth = HoldRingStroke
        )
        ChronirText(
            text = label,
            style = ChronirTextStyle.LabelLarge,
            color = contentColor,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun HoldToCompleteButtonPreview() {
    ChronirTheme(dynamicColor = false) {
        Box(modifier = Modifier.padding(SpacingTokens.Medium)) {
            HoldToCompleteButton(onComplete = {})
        }
    }
}

@ChronirPreview
@Composable
private fun HoldToCompleteButtonFiringPreview() {
    ChronirTheme(dynamicColor = false) {
        Box(
            modifier = Modifier
                .background(ColorTokens.FiringBackground)
                .padding(SpacingTokens.Medium)
        ) {
            HoldToCompleteButton(
                onComplete = {},
                label = "Hold to Dismiss",
                progressColor = ColorTokens.FiringControlProgress,
                trackColor = ColorTokens.FiringControlFill,
                contentColor = ColorTokens.FiringTextPrimary
            )
        }
    }
}
