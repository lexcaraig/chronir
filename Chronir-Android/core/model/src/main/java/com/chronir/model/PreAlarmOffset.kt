package com.chronir.model

enum class PreAlarmOffset(
    val minutes: Int,
    val displayName: String
) {
    NONE(0, "None"),
    FIFTEEN_MINUTES(15, "15 min before"),
    THIRTY_MINUTES(30, "30 min before"),
    ONE_HOUR(60, "1 hour before"),
    TWO_HOURS(120, "2 hours before"),
    TWELVE_HOURS(720, "12 hours before"),
    ONE_DAY(1440, "1 day before"),
    TWO_DAYS(2880, "2 days before"),
    ONE_WEEK(10080, "1 week before");

    companion object {
        fun fromMinutes(minutes: Int): PreAlarmOffset = entries.firstOrNull { it.minutes == minutes } ?: NONE
    }
}
