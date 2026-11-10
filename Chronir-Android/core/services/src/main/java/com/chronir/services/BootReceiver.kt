package com.chronir.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.chronir.data.repository.AlarmRepository
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

/**
 * Re-registers every enabled alarm whenever AlarmManager's registrations or the stored fire dates can no longer
 * be trusted: device boot (including the HTC/Sony quick-boot variant), an app update, and
 * wall-clock or timezone changes. Not exported: all of these are system broadcasts, and QUICKBOOT_POWERON
 * is unprotected, so an exported receiver would let any app trigger a re-registration storm.
 */
@AndroidEntryPoint
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val ACTION_QUICKBOOT_POWERON = "android.intent.action.QUICKBOOT_POWERON"

        private val HANDLED_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            ACTION_QUICKBOOT_POWERON,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED
        )
    }

    @Inject
    lateinit var alarmRepository: AlarmRepository

    @Inject
    lateinit var alarmScheduler: AlarmScheduler

    @Inject
    lateinit var dateCalculator: DateCalculator

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in HANDLED_ACTIONS) return

        val pendingResult = goAsync()
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

        scope.launch {
            try {
                val policy = AlarmReregistrationPolicy(dateCalculator, alarmScheduler)
                val changed = policy.reregister(alarmRepository.getEnabledAlarms(), Instant.now())
                changed.forEach { alarmRepository.updateAlarm(it) }
            } catch (e: Exception) {
                // A Room or scheduler failure must not crash the process from a broadcast.
                Log.e("BootReceiver", "re-registration failed for ${intent.action}: ${e.javaClass.simpleName}")
            } finally {
                pendingResult.finish()
            }
        }
    }
}
