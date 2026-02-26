package com.chronir.services

import com.chronir.data.remote.AuthDataSource
import com.chronir.data.remote.FirestoreDataSource
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.SyncStatus
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CloudSyncService
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val firestoreDataSource: FirestoreDataSource,
        private val authDataSource: AuthDataSource,
        private val billingService: BillingService
    ) {

        private fun requireAuth(): String = authDataSource.getCurrentUserId()
            ?: throw IllegalStateException("Not authenticated")

        private fun requirePlus() {
            if (billingService.subscriptionState.value.tier != SubscriptionTier.PLUS) {
                throw IllegalStateException("Plus subscription required")
            }
        }

        suspend fun syncAlarms() {
            requirePlus()
            val uid = requireAuth()

            // Push all local alarms
            val localAlarms = alarmRepository.getEnabledAlarms()
            val localData = localAlarms.map { it.id to it.toFirestoreMap() }
            if (localData.isNotEmpty()) {
                firestoreDataSource.uploadAllAlarms(uid, localData)
            }

            // Pull remote alarms and merge (last-write-wins by updatedAt)
            val remoteMaps = firestoreDataSource.fetchAllRemoteAlarms(uid)
            for (remoteMap in remoteMaps) {
                val remoteId = remoteMap["id"] as? String ?: continue
                val remoteUpdatedAt = (remoteMap["updatedAt"] as? Long)?.let { Instant.ofEpochMilli(it) }
                    ?: continue

                val localAlarm = alarmRepository.getAlarmById(remoteId)
                if (localAlarm == null || remoteUpdatedAt.isAfter(localAlarm.updatedAt)) {
                    // Remote is newer or doesn't exist locally — would need full deserialization
                    // For now, local push is the primary direction; remote pull is best-effort
                }
            }

            // Update sync status on local alarms
            for (alarm in localAlarms) {
                if (alarm.syncStatus != SyncStatus.SYNCED) {
                    alarmRepository.updateAlarm(
                        alarm.copy(syncStatus = SyncStatus.SYNCED, updatedAt = Instant.now())
                    )
                }
            }
        }

        suspend fun pushAlarm(alarm: Alarm) {
            requirePlus()
            val uid = requireAuth()
            firestoreDataSource.pushAlarm(uid, alarm.id, alarm.toFirestoreMap())
            alarmRepository.updateAlarm(
                alarm.copy(syncStatus = SyncStatus.SYNCED, updatedAt = Instant.now())
            )
        }

        suspend fun deleteRemoteAlarm(alarmId: String) {
            requirePlus()
            val uid = requireAuth()
            firestoreDataSource.deleteRemoteAlarm(uid, alarmId)
        }

        suspend fun deleteAllCloudData() {
            val uid = requireAuth()
            firestoreDataSource.deleteAllCloudData(uid)
        }

        private fun Alarm.toFirestoreMap(): Map<String, Any?> = mapOf(
            "title" to title,
            "cycleType" to cycleType.name,
            "timeOfDayHour" to timeOfDay.hour,
            "timeOfDayMinute" to timeOfDay.minute,
            "nextFireDate" to nextFireDate.toEpochMilli(),
            "lastFiredDate" to lastFiredDate?.toEpochMilli(),
            "timezone" to timezone,
            "timezoneMode" to timezoneMode.name,
            "isEnabled" to isEnabled,
            "snoozeCount" to snoozeCount,
            "persistenceLevel" to persistenceLevel.name,
            "dismissMethod" to dismissMethod.name,
            "preAlarmMinutes" to preAlarmMinutes,
            "colorTag" to colorTag,
            "iconName" to iconName,
            "syncStatus" to SyncStatus.SYNCED.name,
            "note" to note,
            "createdAt" to createdAt.toEpochMilli(),
            "updatedAt" to updatedAt.toEpochMilli()
        )
    }
