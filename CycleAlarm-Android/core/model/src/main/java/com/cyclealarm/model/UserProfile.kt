package com.cyclealarm.model

import java.time.Instant
import java.util.UUID

data class UserProfile(
    val id: String = UUID.randomUUID().toString(),
    val displayName: String,
    val email: String,
    val photoUrl: String? = null,
    val isPremium: Boolean = false,
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now()
)
