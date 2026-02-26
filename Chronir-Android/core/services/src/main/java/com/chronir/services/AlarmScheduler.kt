package com.chronir.services

import android.app.AlarmManager
import android.app.AlarmManager.AlarmClockInfo
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.chronir.model.Alarm
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

interface AlarmScheduler {
    fun schedule(alarm: Alarm)

    fun cancel(alarmId: String)
}

@Singleton
class AlarmSchedulerImpl
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) : AlarmScheduler {

        private val alarmManager: AlarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        override fun schedule(alarm: Alarm) {
            val triggerAtMillis = alarm.nextFireDate.toEpochMilli()

            val timeText = "%d:%02d %s".format(
                if (alarm.timeOfDay.hour % 12 == 0) 12 else alarm.timeOfDay.hour % 12,
                alarm.timeOfDay.minute,
                if (alarm.timeOfDay.hour < 12) "AM" else "PM"
            )

            val intent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarm.id)
                putExtra(AlarmReceiver.EXTRA_ALARM_TITLE, alarm.title)
                putExtra(AlarmReceiver.EXTRA_ALARM_TIME, timeText)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarm.id.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Show intent opens the firing activity when the user taps the alarm icon in status bar
            val showIntent = Intent().apply {
                setClassName(context.packageName, "com.chronir.feature.alarmfiring.AlarmFiringActivity")
                putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarm.id)
            }
            val showPendingIntent = PendingIntent.getActivity(
                context,
                alarm.id.hashCode() + 1,
                showIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val clockInfo = AlarmClockInfo(triggerAtMillis, showPendingIntent)
            alarmManager.setAlarmClock(clockInfo, pendingIntent)

            // Schedule pre-alarm notification if enabled
            if (alarm.preAlarmMinutes > 0) {
                val preAlarmMillis = triggerAtMillis - (alarm.preAlarmMinutes * 60 * 1000L)
                if (preAlarmMillis > System.currentTimeMillis()) {
                    schedulePreAlarm(alarm.id, alarm.title, preAlarmMillis)
                }
            } else {
                cancelPreAlarm(alarm.id)
            }
        }

        override fun cancel(alarmId: String) {
            val intent = Intent(context, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
            cancelPreAlarm(alarmId)
        }

        private fun schedulePreAlarm(alarmId: String, alarmTitle: String, triggerAtMillis: Long) {
            val intent = Intent(context, PreAlarmReceiver::class.java).apply {
                putExtra(PreAlarmReceiver.EXTRA_ALARM_ID, alarmId)
                putExtra(PreAlarmReceiver.EXTRA_ALARM_TITLE, alarmTitle)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode() + 2,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        }

        private fun cancelPreAlarm(alarmId: String) {
            val intent = Intent(context, PreAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode() + 2,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
    }
