package com.chronir.data.repository

import com.chronir.data.local.CompletionDao
import com.chronir.data.local.CompletionEntity
import com.chronir.model.CompletionAction
import com.chronir.model.CompletionRecord
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CompletionRepository
    @Inject
    constructor(
        private val completionDao: CompletionDao
    ) {

        fun observeByAlarmId(alarmId: String): Flow<List<CompletionRecord>> = completionDao.observeByAlarmId(alarmId).map { entities ->
            entities.map { it.toDomain() }
        }

        fun observeRecent(limit: Int = 50): Flow<List<CompletionRecord>> = completionDao.observeRecent(limit).map { entities ->
            entities.map { it.toDomain() }
        }

        suspend fun recordCompletion(
            alarmId: String,
            action: CompletionAction,
            snoozeDurationMinutes: Int? = null
        ) {
            val entity = CompletionEntity(
                id = UUID.randomUUID().toString(),
                alarmId = alarmId,
                action = action.name,
                timestamp = Instant.now().toEpochMilli(),
                snoozeDurationMinutes = snoozeDurationMinutes
            )
            completionDao.insert(entity)
        }

        suspend fun getCompletionCount(alarmId: String): Int = completionDao.getCompletionCount(alarmId)

        suspend fun deleteByAlarmId(alarmId: String) {
            completionDao.deleteByAlarmId(alarmId)
        }

        private fun CompletionEntity.toDomain(): CompletionRecord = CompletionRecord(
            id = id,
            alarmId = alarmId,
            userId = "",
            action = CompletionAction.valueOf(action),
            timestamp = Instant.ofEpochMilli(timestamp),
            snoozeDurationMinutes = snoozeDurationMinutes
        )
    }
