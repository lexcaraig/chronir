package com.chronir.designsystem.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.platform.LocalContext
import com.chronir.designsystem.tokens.ChronirColors
import com.chronir.designsystem.tokens.ColorSchemeTokens
import com.chronir.designsystem.tokens.ExtendedColorTokens
import com.chronir.designsystem.tokens.TypographyTokens

/** Chronir roles with no Material 3 slot, resolved for the current light/dark theme. */
val LocalChronirColors = staticCompositionLocalOf { ExtendedColorTokens.Light }

/** Chronir extended colors (textTertiary, textError, textWarning, onPrimary, borders, icons). */
val MaterialTheme.chronirColors: ChronirColors
    @Composable
    @ReadOnlyComposable
    get() = LocalChronirColors.current

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
            DynamicColorProvider.applyChronirOverrides(dynamic, darkTheme)
        }
        darkTheme -> ColorSchemeTokens.Dark
        else -> ColorSchemeTokens.Light
    }

    val typography = if (textScale != 1f) {
        TypographyTokens.scaledTypography(textScale)
    } else {
        TypographyTokens.AppTypography
    }

    CompositionLocalProvider(
        LocalChronirColors provides if (darkTheme) ExtendedColorTokens.Dark else ExtendedColorTokens.Light
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = typography,
            content = content
        )
    }
}
