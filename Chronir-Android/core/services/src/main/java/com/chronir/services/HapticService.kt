package com.chronir.services

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class HapticService @Inject constructor(
    @ApplicationContext private val context: Context
) {

    private val vibrator: Vibrator by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    fun lightTap() {
        vibrator.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
    }

    fun mediumTap() {
        vibrator.vibrate(VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE))
    }

    fun alarmPattern() {
        val timings = longArrayOf(0, 500, 200, 500, 200, 500)
        val amplitudes = intArrayOf(0, 255, 0, 255, 0, 255)
        vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, 0))
    }

    fun cancel() {
        vibrator.cancel()
    }
}
