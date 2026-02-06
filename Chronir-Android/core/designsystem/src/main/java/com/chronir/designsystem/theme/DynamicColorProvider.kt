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
     * Alarm-specific and semantic colors should remain consistent
     * regardless of the user's wallpaper-derived palette.
     */
    fun applyChronirOverrides(scheme: ColorScheme): ColorScheme {
        return scheme.copy(
            error = ColorTokens.Error,
            onError = ColorTokens.OnError,
            errorContainer = ColorTokens.ErrorContainer,
            onErrorContainer = ColorTokens.OnErrorContainer
        )
    }
}
