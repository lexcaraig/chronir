package com.chronir.designsystem.molecules

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.ColorTokens
import kotlinx.coroutines.launch

@Composable
fun HoldToCompleteButton(
    onComplete: () -> Unit,
    modifier: Modifier = Modifier,
    holdDurationMs: Long = 3000L,
    label: String = "Hold to Complete"
) {
    val progress = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()

    Box(
        modifier = modifier
            .size(120.dp)
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        scope.launch {
                            progress.animateTo(
                                targetValue = 1f,
                                animationSpec = tween(
                                    durationMillis = holdDurationMs.toInt(),
                                    easing = LinearEasing
                                )
                            )
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
            modifier = Modifier.size(120.dp),
            color = ColorTokens.Success,
            trackColor = MaterialTheme.colorScheme.surfaceVariant,
            strokeWidth = 6.dp
        )
        ChronirText(
            text = label,
            style = ChronirTextStyle.LabelSmall,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}
