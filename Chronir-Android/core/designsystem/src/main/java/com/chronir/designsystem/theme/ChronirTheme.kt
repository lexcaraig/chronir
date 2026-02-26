package com.chronir.designsystem.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.TypographyTokens

private val LightColorScheme = lightColorScheme(
    primary = ColorTokens.Neutral900, // #3B3D42
    onPrimary = ColorTokens.Neutral0, // #FFFFFF
    primaryContainer = ColorTokens.Neutral800, // #505258
    onPrimaryContainer = ColorTokens.Neutral0, // #FFFFFF
    secondary = ColorTokens.Neutral800, // #505258
    onSecondary = ColorTokens.Neutral0, // #FFFFFF
    secondaryContainer = ColorTokens.Neutral200, // #F0F1F2
    onSecondaryContainer = ColorTokens.Neutral1100, // #1E1F21
    tertiary = ColorTokens.Amber500, // #FFB800
    onTertiary = ColorTokens.Neutral1100, // #1E1F21
    tertiaryContainer = Color(0xFFCC9300),
    onTertiaryContainer = ColorTokens.Neutral1100,
    error = ColorTokens.Error,
    onError = ColorTokens.OnError,
    errorContainer = ColorTokens.ErrorContainer,
    onErrorContainer = ColorTokens.OnErrorContainer,
    surface = ColorTokens.LightBackground, // #FFFFFF
    onSurface = ColorTokens.LightTextPrimary, // #1E1F21
    surfaceVariant = ColorTokens.LightBackgroundSecondary, // #F8F8F8
    onSurfaceVariant = ColorTokens.LightTextSecondary, // #6B6E76
    background = ColorTokens.LightBackground, // #FFFFFF
    onBackground = ColorTokens.LightTextPrimary, // #1E1F21
    outline = ColorTokens.LightBorderDefault, // #DDDEE1
    outlineVariant = ColorTokens.Neutral400 // #B7B9BE
)

private val DarkColorScheme = darkColorScheme(
    primary = ColorTokens.Neutral900, // #3B3D42
    onPrimary = ColorTokens.Neutral0, // #FFFFFF
    primaryContainer = ColorTokens.Neutral800, // #505258
    onPrimaryContainer = ColorTokens.DarkNeutral1100, // #E2E3E4
    secondary = ColorTokens.Neutral800, // #505258
    onSecondary = ColorTokens.Neutral0, // #FFFFFF
    secondaryContainer = ColorTokens.DarkNeutral300, // #303134
    onSecondaryContainer = ColorTokens.DarkNeutral1100, // #E2E3E4
    tertiary = ColorTokens.Amber500, // #FFB800
    onTertiary = ColorTokens.Neutral1100, // #1E1F21
    tertiaryContainer = Color(0xFFCC9300),
    onTertiaryContainer = ColorTokens.Neutral1100,
    error = ColorTokens.Error,
    onError = ColorTokens.OnError,
    errorContainer = ColorTokens.ErrorContainer,
    onErrorContainer = ColorTokens.OnErrorContainer,
    surface = ColorTokens.DarkBackground, // #242528
    onSurface = ColorTokens.DarkTextPrimary, // #E2E3E4
    surfaceVariant = ColorTokens.DarkSurfaceCard, // #303134
    onSurfaceVariant = ColorTokens.DarkTextSecondary, // #96999E
    background = ColorTokens.DarkBackground, // #242528
    onBackground = ColorTokens.DarkTextPrimary, // #E2E3E4
    outline = ColorTokens.DarkBorderDefault, // #303134
    outlineVariant = ColorTokens.DarkNeutral400 // #4B4D51
)

@Composable
fun ChronirTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    textScale: Float = 1f,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            val dynamic = if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
            DynamicColorProvider.applyChronirOverrides(dynamic)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    val typography = if (textScale != 1f) {
        TypographyTokens.scaledTypography(textScale)
    } else {
        TypographyTokens.AppTypography
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = typography,
        content = content
    )
}
