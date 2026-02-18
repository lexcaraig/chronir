package com.chronir.designsystem.theme

import android.content.Context
import android.os.Build
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import com.chronir.designsystem.tokens.ColorTokens

object DynamicColorProvider {

    fun isSupported(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
    }

    fun getDynamicColorScheme(context: Context, darkTheme: Boolean): ColorScheme? {
        if (!isSupported()) return null
        return if (darkTheme) {
            dynamicDarkColorScheme(context)
        } else {
            dynamicLightColorScheme(context)
        }
    }

    /**
     * Applies Chronir brand overrides on top of a dynamic color scheme.
     * All brand colors are overridden to maintain the neutral Chronir palette
     * regardless of the user's wallpaper-derived colors.
     */
    fun applyChronirOverrides(scheme: ColorScheme): ColorScheme {
        return scheme.copy(
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
    }
}
