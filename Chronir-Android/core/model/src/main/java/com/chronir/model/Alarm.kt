package com.chronir.model

import java.time.Instant
import java.time.LocalTime
import java.util.UUID

enum class CycleType {
    WEEKLY,
    BIWEEKLY,
    MONTHLY,
    QUARTERLY,
    BIANNUAL,
    ANNUAL,
    CUSTOM
}

data class Alarm(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val cycleType: CycleType,
    val scheduledTime: LocalTime,
    val nextFireDate: Instant,
    val isEnabled: Boolean = true,
    val isPersistent: Boolean = false,
    val note: String = "",
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now()
)
