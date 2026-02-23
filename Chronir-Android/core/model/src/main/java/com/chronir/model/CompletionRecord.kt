package com.chronir.model

import java.time.Instant
import java.util.UUID

enum class CompletionAction {
    COMPLETED,
    SNOOZED,
    MISSED,
    SKIPPED
}

data class CompletionRecord(
    val id: String = UUID.randomUUID().toString(),
    val alarmId: String,
    val userId: String,
    val action: CompletionAction,
    val timestamp: Instant = Instant.now(),
    val snoozeDurationMinutes: Int? = null
)
