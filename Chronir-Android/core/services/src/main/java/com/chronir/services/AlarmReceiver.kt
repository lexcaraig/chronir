package com.chronir.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Schedule
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

@AndroidEntryPoint
class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_ALARM_ID = "extra_alarm_id"
        const val EXTRA_ALARM_TITLE = "extra_alarm_title"
        const val EXTRA_ALARM_TIME = "extra_alarm_time"
    }

    @Inject
    lateinit var alarmRepository: AlarmRepository

    @Inject
    lateinit var alarmScheduler: AlarmScheduler

    @Inject
    lateinit var dateCalculator: DateCalculator

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: return

        val serviceIntent = Intent(context, AlarmFiringService::class.java).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmFiringService.EXTRA_ALARM_TITLE, intent.getStringExtra(EXTRA_ALARM_TITLE))
            putExtra(AlarmFiringService.EXTRA_ALARM_TIME, intent.getStringExtra(EXTRA_ALARM_TIME))
        }
        context.startForegroundService(serviceIntent)

        registerNextOccurrence(alarmId)
    }

    // / Register the following occurrence with AlarmManager right away, independent of
    // / whether the user ever dismisses this one in-app. Until now the next occurrence was
    // / only scheduled by the firing screen, so dismissing from the notification, swiping
    // / it away, or ignoring it left the alarm dead. The stored nextFireDate is left as-is
    // / so the Overdue state still reflects an unacknowledged alarm; dismissing in-app
    // / advances it and re-registers the same PendingIntent.
    private fun registerNextOccurrence(alarmId: String) {
        val pendingResult = goAsync()
        CoroutineScope(SupervisorJob() + Dispatchers.IO).launch {
            try {
                val alarm = alarmRepository.getAlarmById(alarmId) ?: return@launch
                if (!alarm.isEnabled || alarm.schedule is Schedule.OneTime) return@launch
                val next = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                alarmScheduler.schedule(alarm.copy(nextFireDate = next, snoozeCount = 0))
            } finally {
                pendingResult.finish()
            }
        }
    }
}
