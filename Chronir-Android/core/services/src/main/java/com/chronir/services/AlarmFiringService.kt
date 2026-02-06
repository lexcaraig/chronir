package com.chronir.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AlarmFiringService : Service() {

    companion object {
        const val CHANNEL_ID = "alarm_firing_channel"
        const val NOTIFICATION_ID = 1001
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID)

        val notification = buildNotification(alarmId)
        startForeground(NOTIFICATION_ID, notification)

        // TODO: Launch AlarmFiringActivity as full-screen intent
        // TODO: Play alarm sound and vibrate

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Alarm Firing",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Active alarm notifications"
            setBypassDnd(true)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(alarmId: String?): Notification {
        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Alarm Firing")
            .setContentText("Alarm $alarmId is ringing")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .build()
    }
}
