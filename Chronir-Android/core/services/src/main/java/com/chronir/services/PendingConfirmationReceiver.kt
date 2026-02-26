package com.chronir.services

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.model.CompletionAction
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class PendingConfirmationReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_FOLLOW_UP = "com.chronir.ACTION_PENDING_FOLLOW_UP"
        const val ACTION_CONFIRM_DONE = "com.chronir.ACTION_CONFIRM_DONE"
        const val ACTION_REMIND_ME = "com.chronir.ACTION_REMIND_ME"
        const val EXTRA_ALARM_ID = "extra_alarm_id"
        const val EXTRA_ALARM_TITLE = "extra_alarm_title"
    }

    @Inject
    lateinit var alarmRepository: AlarmRepository

    @Inject
    lateinit var completionRepository: CompletionRepository

    @Inject
    lateinit var notificationCleanupService: NotificationCleanupService

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: return
        val alarmTitle = intent.getStringExtra(EXTRA_ALARM_TITLE) ?: "Alarm"

        when (intent.action) {
            ACTION_CONFIRM_DONE -> {
                val pendingResult = goAsync()
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val alarm = alarmRepository.getAlarmById(alarmId) ?: return@launch
                        val updated = alarm.copy(
                            isPendingConfirmation = false,
                            pendingSince = null,
                            updatedAt = java.time.Instant.now()
                        )
                        alarmRepository.updateAlarm(updated)
                        completionRepository.recordCompletion(
                            alarmId = alarmId,
                            action = CompletionAction.COMPLETED
                        )
                        notificationCleanupService.cancelAlarmNotifications(alarmId)
                    } finally {
                        pendingResult.finish()
                    }
                }
            }

            ACTION_REMIND_ME -> {
                // Dismiss this notification; the next follow-up is already scheduled
                val notificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.cancel(alarmId.hashCode() + 200)
                notificationManager.cancel(alarmId.hashCode() + 201)
                notificationManager.cancel(alarmId.hashCode() + 202)
            }

            ACTION_FOLLOW_UP -> {
                showFollowUpNotification(context, alarmId, alarmTitle)
            }
        }
    }

    private fun showFollowUpNotification(context: Context, alarmId: String, title: String) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // "Done" action
        val doneIntent = Intent(context, PendingConfirmationReceiver::class.java).apply {
            action = ACTION_CONFIRM_DONE
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_ALARM_TITLE, title)
        }
        val donePendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode() + 300,
            doneIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // "Remind Me" action
        val remindIntent = Intent(context, PendingConfirmationReceiver::class.java).apply {
            action = ACTION_REMIND_ME
            putExtra(EXTRA_ALARM_ID, alarmId)
        }
        val remindPendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode() + 301,
            remindIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Tap opens app
        val tapIntent = Intent().apply {
            setClassName(context.packageName, "com.chronir.MainActivity")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val tapPendingIntent = PendingIntent.getActivity(
            context,
            alarmId.hashCode() + 302,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = Notification.Builder(context, PendingConfirmationService.CHANNEL_ID)
            .setContentTitle("Did you complete \"$title\"?")
            .setContentText("Tap Done to confirm completion")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setAutoCancel(true)
            .setContentIntent(tapPendingIntent)
            .addAction(
                Notification.Action.Builder(null, "Done", donePendingIntent).build()
            )
            .addAction(
                Notification.Action.Builder(null, "Remind Me", remindPendingIntent).build()
            )
            .build()

        notificationManager.notify(alarmId.hashCode() + 200, notification)
    }
}
