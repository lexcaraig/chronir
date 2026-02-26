package com.chronir.services

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class BatteryOptimizationHelper
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) {

        val manufacturer: String = Build.MANUFACTURER.lowercase()

        val isKnownProblematicOem: Boolean
            get() = manufacturer in setOf(
                "samsung",
                "xiaomi",
                "huawei",
                "oneplus",
                "oppo",
                "vivo",
                "realme",
                "meizu"
            )

        fun isIgnoringBatteryOptimizations(): Boolean {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            return pm.isIgnoringBatteryOptimizations(context.packageName)
        }

        fun getBatterySettingsIntent(): Intent {
            // Try OEM-specific settings first, fall back to standard
            val oemIntent = getOemBatteryIntent()
            if (oemIntent != null &&
                context.packageManager.resolveActivity(oemIntent, 0) != null
            ) {
                return oemIntent
            }

            // Standard Android battery optimization screen
            return Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${context.packageName}")
            }
        }

        private fun getOemBatteryIntent(): Intent? = when (manufacturer) {
            "samsung" -> Intent().apply {
                setClassName(
                    "com.samsung.android.lool",
                    "com.samsung.android.sm.battery.ui.BatteryActivity"
                )
            }
            "xiaomi", "redmi" -> Intent().apply {
                setClassName(
                    "com.miui.powerkeeper",
                    "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"
                )
                putExtra("package_name", context.packageName)
                putExtra("package_label", "Chronir")
            }
            "huawei", "honor" -> Intent().apply {
                setClassName(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                )
            }
            "oneplus" -> Intent().apply {
                setClassName(
                    "com.oneplus.security",
                    "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
                )
            }
            "oppo", "realme" -> Intent().apply {
                setClassName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity"
                )
            }
            "vivo" -> Intent().apply {
                setClassName(
                    "com.vivo.abe",
                    "com.vivo.applicationbehaviorengine.ui.ExcessivePowerManagerActivity"
                )
            }
            else -> null
        }
    }
