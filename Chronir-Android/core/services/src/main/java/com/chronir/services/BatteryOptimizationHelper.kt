package com.chronir.services

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
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
                "redmi",
                "huawei",
                "honor",
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

        /**
         * The OEM's own "background restriction" screen when this device has one and it resolves, otherwise null
         * so the caller falls back to App Info. There is deliberately no
         * ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS fallback: it needs a permission Chronir does not declare.
         */
        fun oemBatterySettingsIntent(): Intent? =
            getOemBatteryIntent()?.takeIf { context.packageManager.resolveActivity(it, 0) != null }

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
