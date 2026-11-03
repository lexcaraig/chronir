package com.chronir.model

import java.time.Duration
import java.time.Instant

/** "Alarm in 5d 14h" / "Alarm in 3h 12m" / "Alarm in 8m" (matches iOS); null once the time has passed. */
fun countdownText(to: Instant, now: Instant = Instant.now()): String? {
    val remaining = Duration.between(now, to)
    if (remaining.isNegative || remaining.isZero) return null
    val days = remaining.toDays()
    val hours = remaining.toHours() % 24
    val minutes = remaining.toMinutes() % 60
    return when {
        days > 0 -> "Alarm in ${days}d ${hours}h"
        hours > 0 -> "Alarm in ${hours}h ${minutes}m"
        else -> "Alarm in ${maxOf(minutes, 1)}m"
    }
}
