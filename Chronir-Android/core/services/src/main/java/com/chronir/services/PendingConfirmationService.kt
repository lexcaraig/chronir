package com.chronir.services

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.model.Alarm
import com.chronir.model.CompletionAction
import dagger.hilt.android.qualifiers.ApplicationContext
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PendingConfirmationService
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
        private val alarmRepository: AlarmRepository,
        private val completionRepository: CompletionRepository,
        private val alarmScheduler: AlarmScheduler,
        private val dateCalculator: DateCalculator,
        private val notificationCleanupService: NotificationCleanupService
    ) {

        companion object {
            const val CHANNEL_ID = "pending_confirmation_channel"
            private const val FOLLOW_UP_COUNT = 3
        }

        private val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        private val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        init {
            createNotificationChannel()
        }

        suspend fun enterPending(alarm: Alarm) {
            val now = Instant.now()
            val updated = alarm.copy(
                isPendingConfirmation = true,
                pendingSince = now,
                lastFiredDate = now,
                snoozeCount = 0,
                updatedAt = now
            )

            // Reschedule to next occurrence so the alarm itself advances
            if (alarm.schedule !is com.chronir.model.Schedule.OneTime) {
                val nextFireDate = dateCalculator.calculateNextFireDate(alarm, now)
                val rescheduled = updated.copy(nextFireDate = nextFireDate)
                alarmRepository.updateAlarm(rescheduled)
                alarmScheduler.schedule(rescheduled)
            } else {
                val disabled = updated.copy(isEnabled = false)
                alarmRepository.updateAlarm(disabled)
                alarmScheduler.cancel(alarm.id)
            }

            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.PENDING_CONFIRMATION
            )

            // Schedule follow-up reminder notifications
            scheduleFollowUpNotifications(alarm)
        }

        suspend fun confirmDone(alarm: Alarm) {
            val updated = alarm.copy(
                isPendingConfirmation = false,
                pendingSince = null,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)

            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.COMPLETED
            )

            cancelFollowUpNotifications(alarm.id)
            notificationCleanupService.cancelAlarmNotifications(alarm.id)
        }

        suspend fun cancelPending(alarm: Alarm) {
            val updated = alarm.copy(
                isPendingConfirmation = false,
                pendingSince = null,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)
            cancelFollowUpNotifications(alarm.id)
            notificationCleanupService.cancelAlarmNotifications(alarm.id)
        }

        suspend fun autoCompletePending(alarm: Alarm) {
            if (!alarm.isPendingConfirmation) return
            val updated = alarm.copy(
                isPendingConfirmation = false,
                pendingSince = null,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)

            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.COMPLETED
            )
            cancelFollowUpNotifications(alarm.id)
        }

        private fun scheduleFollowUpNotifications(alarm: Alarm) {
            val baseTime = System.currentTimeMillis()
            val intervalMillis = alarm.followUpInterval.timeIntervalMillis
            (1..FOLLOW_UP_COUNT).forEachIndexed { index, multiplier ->
                val triggerAt = baseTime + multiplier * intervalMillis
                val intent = Intent(context, PendingConfirmationReceiver::class.java).apply {
                    action = PendingConfirmationReceiver.ACTION_FOLLOW_UP
                    putExtra(PendingConfirmationReceiver.EXTRA_ALARM_ID, alarm.id)
                    putExtra(PendingConfirmationReceiver.EXTRA_ALARM_TITLE, alarm.title)
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    alarm.id.hashCode() + 200 + index,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAt,
                    pendingIntent
                )
            }
        }

        private fun cancelFollowUpNotifications(alarmId: String) {
            (0 until FOLLOW_UP_COUNT).forEach { index ->
                val intent = Intent(context, PendingConfirmationReceiver::class.java)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    alarmId.hashCode() + 200 + index,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                alarmManager.cancel(pendingIntent)
                notificationManager.cancel(alarmId.hashCode() + 200 + index)
            }
        }

        private fun createNotificationChannel() {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Pending Confirmation",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders to confirm alarm task completion"
            }
            notificationManager.createNotificationChannel(channel)
        }
    }
