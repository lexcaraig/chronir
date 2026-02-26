package com.chronir.services

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PermissionHelper
    @Inject
    constructor() {

        /**
         * Checks whether the app can schedule exact alarms.
         * On API 31+ (Android 12+), this requires the SCHEDULE_EXACT_ALARM permission
         * which the user must grant via system settings.
         */
        fun canScheduleExactAlarms(context: Context): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                return alarmManager.canScheduleExactAlarms()
            }
            // Below API 31, exact alarms are always allowed
            return true
        }

        /**
         * Opens the system settings page where the user can grant the exact alarm permission.
         * Only applicable on API 31+.
         */
        fun openExactAlarmSettings(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
            }
        }
    }
