package com.chronir.feature.settings

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.compose.LifecycleResumeEffect

/** Live state of the system permissions alarms depend on. */
data class AlarmReliabilityStatus(
    val notificationsEnabled: Boolean = true,
    /** Android 14+: lets a firing alarm take over the lock screen. Always true below API 34. */
    val fullScreenIntentAllowed: Boolean = true,
    val ignoringBatteryOptimizations: Boolean = true,
    /** USE_EXACT_ALARM (API 33+) is always granted; SCHEDULE_EXACT_ALARM (API 31–32) can be revoked. */
    val exactAlarmsAllowed: Boolean = true
) {
    val allGood: Boolean
        get() = notificationsEnabled && fullScreenIntentAllowed && ignoringBatteryOptimizations && exactAlarmsAllowed

    companion object {
        fun read(context: Context): AlarmReliabilityStatus {
            val fullScreen = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                context.getSystemService(NotificationManager::class.java).canUseFullScreenIntent()
            } else {
                true
            }
            return AlarmReliabilityStatus(
                notificationsEnabled = NotificationManagerCompat.from(context).areNotificationsEnabled(),
                fullScreenIntentAllowed = fullScreen,
                ignoringBatteryOptimizations = context.getSystemService(PowerManager::class.java)
                    .isIgnoringBatteryOptimizations(context.packageName),
                exactAlarmsAllowed = context.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()
            )
        }
    }
}

/** Reads [AlarmReliabilityStatus] and re-reads it every time the screen resumes (e.g. back from Settings). */
@Composable
fun rememberAlarmReliabilityStatus(): AlarmReliabilityStatus {
    val context = LocalContext.current
    var status by remember { mutableStateOf(AlarmReliabilityStatus.read(context)) }
    LifecycleResumeEffect(context) {
        status = AlarmReliabilityStatus.read(context)
        onPauseOrDispose {}
    }
    return status
}

/** Deep links to the system screen that fixes each reliability permission, scoped to this app. */
object AlarmReliabilitySettings {
    private fun packageUri(context: Context) = Uri.parse("package:${context.packageName}")

    fun openNotificationSettings(context: Context) = context.launch(
        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
    )

    fun openFullScreenIntentSettings(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            context.launch(Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, packageUri(context)))
        } else {
            openNotificationSettings(context)
        }
    }

    /** App info for Chronir, where Battery > Unrestricted lives on stock Android. */
    fun openBatterySettings(context: Context) = context.launch(
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri(context))
    )

    fun openExactAlarmSettings(context: Context) = context.launch(
        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, packageUri(context))
    )

    private fun Context.launch(intent: Intent) {
        val withFlags = intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(withFlags)
        } catch (_: ActivityNotFoundException) {
            // Some OEM builds drop the per-app screens; fall back to app info.
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri(this))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        }
    }
}
