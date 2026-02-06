package com.chronir.services

import com.chronir.data.repository.AlarmRepository
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CloudSyncService @Inject constructor(
    private val alarmRepository: AlarmRepository
) {

    suspend fun syncToCloud() {
        // TODO: Push local alarm changes to Firestore
    }

    suspend fun syncFromCloud() {
        // TODO: Pull remote alarm changes from Firestore into Room
    }

    suspend fun resolveConflicts() {
        // TODO: Implement last-write-wins or merge strategy
    }
}
