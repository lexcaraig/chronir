package com.chronir.designsystem.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.TypographyTokens

private val LightColorScheme = lightColorScheme(
    primary = ColorTokens.Primary,
    onPrimary = ColorTokens.OnPrimary,
    primaryContainer = ColorTokens.PrimaryContainer,
    onPrimaryContainer = ColorTokens.OnPrimaryContainer,
    secondary = ColorTokens.Secondary,
    onSecondary = ColorTokens.OnSecondary,
    secondaryContainer = ColorTokens.SecondaryContainer,
    onSecondaryContainer = ColorTokens.OnSecondaryContainer,
    tertiary = ColorTokens.Tertiary,
    onTertiary = ColorTokens.OnTertiary,
    tertiaryContainer = ColorTokens.TertiaryContainer,
    onTertiaryContainer = ColorTokens.OnTertiaryContainer,
    error = ColorTokens.Error,
    onError = ColorTokens.OnError,
    errorContainer = ColorTokens.ErrorContainer,
    onErrorContainer = ColorTokens.OnErrorContainer,
    surface = ColorTokens.SurfacePrimary,
    onSurface = ColorTokens.Gray900,
    surfaceVariant = ColorTokens.Gray100,
    onSurfaceVariant = ColorTokens.Gray800,
    background = ColorTokens.SurfacePrimary,
    onBackground = ColorTokens.Gray900,
    outline = ColorTokens.Outline,
    outlineVariant = ColorTokens.OutlineVariant
)

private val DarkColorScheme = darkColorScheme(
    primary = ColorTokens.Primary,
    onPrimary = ColorTokens.OnPrimary,
    primaryContainer = ColorTokens.PrimaryContainer,
    onPrimaryContainer = ColorTokens.OnPrimaryContainer,
    secondary = ColorTokens.Secondary,
    onSecondary = ColorTokens.OnSecondary,
    secondaryContainer = ColorTokens.SecondaryContainer,
    onSecondaryContainer = ColorTokens.OnSecondaryContainer,
    tertiary = ColorTokens.Tertiary,
    onTertiary = ColorTokens.OnTertiary,
    tertiaryContainer = ColorTokens.TertiaryContainer,
    onTertiaryContainer = ColorTokens.OnTertiaryContainer,
    error = ColorTokens.Error,
    onError = ColorTokens.OnError,
    errorContainer = ColorTokens.ErrorContainer,
    onErrorContainer = ColorTokens.OnErrorContainer,
    surface = ColorTokens.Surface,
    onSurface = ColorTokens.OnSurface,
    surfaceVariant = ColorTokens.SurfaceVariant,
    onSurfaceVariant = ColorTokens.OnSurfaceVariant,
    background = ColorTokens.Background,
    onBackground = ColorTokens.OnBackground,
    outline = ColorTokens.Outline,
    outlineVariant = ColorTokens.OutlineVariant
)

@Composable
fun ChronirTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
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

    MaterialTheme(
        colorScheme = colorScheme,
        typography = TypographyTokens.AppTypography,
        content = content
    )
}
