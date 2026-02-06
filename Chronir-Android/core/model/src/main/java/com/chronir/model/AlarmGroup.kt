package com.chronir.model

import java.time.Instant
import java.util.UUID

data class AlarmGroup(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val ownerUserId: String,
    val memberUserIds: List<String> = emptyList(),
    val alarmIds: List<String> = emptyList(),
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now()
)
