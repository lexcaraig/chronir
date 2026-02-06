package com.cyclealarm.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        // TODO: Reschedule all enabled alarms after device reboot
        // Retrieve enabled alarms from the database and re-register them
        // with the AlarmScheduler.
    }
}
