package com.cyclealarm.data.repository

import com.cyclealarm.data.local.AlarmDao
import com.cyclealarm.data.local.AlarmEntity
import com.cyclealarm.data.remote.FirestoreDataSource
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AlarmRepository @Inject constructor(
    private val alarmDao: AlarmDao,
    private val firestoreDataSource: FirestoreDataSource
) {

    fun observeAlarms(): Flow<List<AlarmEntity>> {
        return alarmDao.observeAll()
    }

    suspend fun getAlarmById(id: String): AlarmEntity? {
        return alarmDao.getById(id)
    }

    suspend fun getEnabledAlarms(): List<AlarmEntity> {
        return alarmDao.getEnabled()
    }

    suspend fun saveAlarm(alarm: AlarmEntity) {
        alarmDao.insert(alarm)
    }

    suspend fun updateAlarm(alarm: AlarmEntity) {
        alarmDao.update(alarm)
    }

    suspend fun deleteAlarm(id: String) {
        alarmDao.deleteById(id)
    }
}
