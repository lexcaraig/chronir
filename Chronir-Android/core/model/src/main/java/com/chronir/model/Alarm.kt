package com.chronir.model

import java.time.Instant
import java.time.LocalTime
import java.util.UUID

enum class CycleType {
    ONE_TIME,
    WEEKLY,
    MONTHLY_DATE,
    MONTHLY_RELATIVE,
    ANNUAL,
    CUSTOM_DAYS;

    val displayName: String
        get() = when (this) {
            ONE_TIME -> "One-Time"
            WEEKLY -> "Weekly"
            MONTHLY_DATE -> "Monthly"
            MONTHLY_RELATIVE -> "Monthly"
            ANNUAL -> "Annual"
            CUSTOM_DAYS -> "Custom"
        }
}

data class Alarm(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val cycleType: CycleType = CycleType.WEEKLY,
    val timeOfDay: LocalTime = LocalTime.of(8, 0),
    val schedule: Schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
    val nextFireDate: Instant = Instant.now(),
    val lastFiredDate: Instant? = null,
    val timezone: String = java.util.TimeZone.getDefault().id,
    val timezoneMode: TimezoneMode = TimezoneMode.FLOATING,
    val isEnabled: Boolean = true,
    val snoozeCount: Int = 0,
    val persistenceLevel: PersistenceLevel = PersistenceLevel.NOTIFICATION_ONLY,
    val dismissMethod: DismissMethod = DismissMethod.SWIPE,
    val preAlarmMinutes: Int = 0,
    val colorTag: String? = null,
    val iconName: String? = null,
    val syncStatus: SyncStatus = SyncStatus.LOCAL_ONLY,
    val ownerID: String? = null,
    val sharedWith: List<String> = emptyList(),
    val note: String = "",
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now()
) {
    val isPersistent: Boolean
        get() = persistenceLevel == PersistenceLevel.FULL
}
