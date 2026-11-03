package com.chronir.designsystem.util

import android.text.format.DateFormat
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import java.time.format.DateTimeFormatter
import java.util.Locale

/**
 * Formatter that follows the device locale and its 12/24-hour setting ("8:00 PM" / "20:00").
 * [dateSkeleton] prepends a date part using ICU skeleton letters, e.g. `"MMMd"` gives
 * "Nov 3, 8:00 PM" or "3 Nov, 20:00".
 */
@Composable
fun rememberTimeFormatter(dateSkeleton: String = ""): DateTimeFormatter {
    val context = LocalContext.current
    val locale = LocalConfiguration.current.locales[0] ?: Locale.getDefault()
    val is24Hour = DateFormat.is24HourFormat(context)
    return remember(locale, is24Hour, dateSkeleton) {
        val skeleton = dateSkeleton + if (is24Hour) "Hm" else "hmm"
        DateTimeFormatter.ofPattern(DateFormat.getBestDateTimePattern(locale, skeleton), locale)
    }
}
