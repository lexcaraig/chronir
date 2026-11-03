package com.chronir.designsystem.theme

import android.content.Context
import android.os.Build
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import com.chronir.designsystem.tokens.ColorSchemeTokens

object DynamicColorProvider {

    fun isSupported(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S

    fun getDynamicColorScheme(context: Context, darkTheme: Boolean): ColorScheme? {
        if (!isSupported()) return null
        return if (darkTheme) {
            dynamicDarkColorScheme(context)
        } else {
            dynamicLightColorScheme(context)
        }
    }

    /**
     * Applies Chronir brand accents on top of a dynamic (wallpaper) scheme.
     *
     * Only the accent families (primary / secondary / tertiary / error and their on-, container and
     * inverse roles, plus surfaceTint) are replaced, and always from the Chronir scheme that MATCHES
     * [darkTheme]. Surfaces, containers, outlines and their on-colors stay from [scheme], so every
     * text/surface pair still comes from one coherent scheme. (The previous version forced dark-only
     * surface roles onto light dynamic schemes, giving ~1.1:1 text in sheets and dialogs.)
     */
    fun applyChronirOverrides(scheme: ColorScheme, darkTheme: Boolean): ColorScheme {
        val brand = if (darkTheme) ColorSchemeTokens.Dark else ColorSchemeTokens.Light
        return scheme.copy(
            primary = brand.primary,
            onPrimary = brand.onPrimary,
            primaryContainer = brand.primaryContainer,
            onPrimaryContainer = brand.onPrimaryContainer,
            inversePrimary = brand.inversePrimary,
            secondary = brand.secondary,
            onSecondary = brand.onSecondary,
            secondaryContainer = brand.secondaryContainer,
            onSecondaryContainer = brand.onSecondaryContainer,
            tertiary = brand.tertiary,
            onTertiary = brand.onTertiary,
            tertiaryContainer = brand.tertiaryContainer,
            onTertiaryContainer = brand.onTertiaryContainer,
            error = brand.error,
            onError = brand.onError,
            errorContainer = brand.errorContainer,
            onErrorContainer = brand.onErrorContainer,
            surfaceTint = brand.surfaceTint
        )
    }
}
