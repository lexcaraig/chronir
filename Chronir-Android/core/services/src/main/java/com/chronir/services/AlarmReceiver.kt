package com.chronir.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_ALARM_ID = "extra_alarm_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: return

        val serviceIntent = Intent(context, AlarmFiringService::class.java).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
        }
        context.startForegroundService(serviceIntent)
    }
}
