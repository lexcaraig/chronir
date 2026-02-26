package com.chronir.services

import android.app.NotificationManager
import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

interface NotificationCleanupService {
    fun cancelAlarmNotifications(alarmId: String)

    fun cancelAllAlarmNotifications()
}

@Singleton
class NotificationCleanupServiceImpl
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) : NotificationCleanupService {

        private val notificationManager: NotificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        override fun cancelAlarmNotifications(alarmId: String) {
            // Cancel the firing notification (fixed ID used by AlarmFiringService)
            notificationManager.cancel(AlarmFiringService.NOTIFICATION_ID)
            // Cancel pre-alarm notification (uses alarmId hash + offset)
            notificationManager.cancel(alarmId.hashCode() + 100)
            // Cancel any pending confirmation follow-up notifications
            notificationManager.cancel(alarmId.hashCode() + 200)
            notificationManager.cancel(alarmId.hashCode() + 201)
            notificationManager.cancel(alarmId.hashCode() + 202)
        }

        override fun cancelAllAlarmNotifications() {
            notificationManager.cancelAll()
        }
    }
