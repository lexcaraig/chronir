package com.chronir.designsystem.templates

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.ColorTokens

/**
 * Host for the alarm firing screen. Always dark (FiringBackground / FiringTextPrimary) whatever the
 * app theme, so loading and content states share one ground and nothing flashes light at night.
 */
@Composable
fun FullScreenAlarmTemplate(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(ColorTokens.FiringBackground),
        contentAlignment = Alignment.Center
    ) {
        CompositionLocalProvider(LocalContentColor provides ColorTokens.FiringTextPrimary) {
            content()
        }
    }
}

@ChronirThemePreview
@Composable
private fun FullScreenAlarmTemplatePreview() {
    ChronirTheme(dynamicColor = false) {
        FullScreenAlarmTemplate {
            ChronirText(text = "Loading alarm", style = ChronirTextStyle.BodyPrimary)
        }
    }
}
