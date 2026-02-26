package com.chronir.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_ALARM_ID = "extra_alarm_id"
        const val EXTRA_ALARM_TITLE = "extra_alarm_title"
        const val EXTRA_ALARM_TIME = "extra_alarm_time"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: return

        val serviceIntent = Intent(context, AlarmFiringService::class.java).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmFiringService.EXTRA_ALARM_TITLE, intent.getStringExtra(EXTRA_ALARM_TITLE))
            putExtra(AlarmFiringService.EXTRA_ALARM_TIME, intent.getStringExtra(EXTRA_ALARM_TIME))
        }
        context.startForegroundService(serviceIntent)
    }
}
