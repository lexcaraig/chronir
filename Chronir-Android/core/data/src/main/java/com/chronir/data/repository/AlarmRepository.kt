package com.chronir.data.repository

import com.chronir.data.local.AlarmDao
import com.chronir.data.mapper.toDomain
import com.chronir.data.mapper.toEntity
import com.chronir.data.remote.FirestoreDataSource
import com.chronir.model.Alarm
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AlarmRepository
    @Inject
    constructor(
        private val alarmDao: AlarmDao,
        private val firestoreDataSource: FirestoreDataSource
    ) {

        fun observeAlarms(): Flow<List<Alarm>> = alarmDao.observeAll().map { entities ->
            entities.map { it.toDomain() }
        }

        suspend fun getAlarmById(id: String): Alarm? = alarmDao.getById(id)?.toDomain()

        suspend fun getEnabledAlarms(): List<Alarm> = alarmDao.getEnabled().map { it.toDomain() }

        suspend fun saveAlarm(alarm: Alarm) {
            alarmDao.insert(alarm.toEntity())
        }

        suspend fun updateAlarm(alarm: Alarm) {
            alarmDao.update(alarm.toEntity())
        }

        suspend fun deleteAlarm(id: String) {
            alarmDao.deleteById(id)
        }
    }
