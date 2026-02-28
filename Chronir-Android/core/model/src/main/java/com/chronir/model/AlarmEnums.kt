package com.chronir.model

enum class TimezoneMode {
    FIXED,
    FLOATING
}

enum class PersistenceLevel {
    FULL,
    NOTIFICATION_ONLY,
    SILENT
}

enum class DismissMethod {
    SWIPE,
    HOLD_3S,
    SOLVE_MATH
}

enum class SyncStatus {
    LOCAL_ONLY,
    SYNCED,
    PENDING_SYNC,
    CONFLICT
}

enum class FollowUpInterval(val minutes: Int) {
    FIFTEEN_MINUTES(15),
    THIRTY_MINUTES(30),
    ONE_HOUR(60),
    TWO_HOURS(120),
    THREE_HOURS(180);

    val displayName: String
        get() = when (this) {
            FIFTEEN_MINUTES -> "15 min"
            THIRTY_MINUTES -> "30 min"
            ONE_HOUR -> "1 hour"
            TWO_HOURS -> "2 hours"
            THREE_HOURS -> "3 hours"
        }

    val timeIntervalMillis: Long
        get() = minutes * 60 * 1000L

    companion object {
        fun fromMinutes(minutes: Int): FollowUpInterval =
            entries.find { it.minutes == minutes } ?: THIRTY_MINUTES
    }
}
