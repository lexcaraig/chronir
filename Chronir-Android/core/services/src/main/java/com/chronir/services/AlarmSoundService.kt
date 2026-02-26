package com.chronir.services

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

data class SoundOption(
    val id: String,
    val displayName: String,
    val isPlusTier: Boolean = false
)

@Singleton
class AlarmSoundService
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) {
        private var mediaPlayer: MediaPlayer? = null

        val allSounds: List<SoundOption> = listOf(
            SoundOption("default", "Default Alarm"),
            SoundOption("gentle", "Gentle Chime"),
            SoundOption("digital", "Digital Pulse", isPlusTier = true),
            SoundOption("soft", "Soft Note", isPlusTier = true),
            SoundOption("quick", "Quick Alert", isPlusTier = true),
            SoundOption("anticipate", "Anticipate", isPlusTier = true)
        )

        fun previewSound(soundId: String) {
            stopPreview()
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                try {
                    val resId = getSoundResourceId(soundId)
                    if (resId != 0) {
                        val afd = context.resources.openRawResourceFd(resId)
                        setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                        afd.close()
                    } else {
                        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        setDataSource(context, uri)
                    }
                    prepare()
                    start()
                } catch (_: Exception) {
                    // Fallback to system default
                    try {
                        reset()
                        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        setDataSource(context, uri)
                        prepare()
                        start()
                    } catch (_: Exception) {
                    }
                }
            }
        }

        fun stopPreview() {
            mediaPlayer?.apply {
                if (isPlaying) stop()
                release()
            }
            mediaPlayer = null
        }

        private fun getSoundResourceId(soundId: String): Int = context.resources.getIdentifier(
            "alarm_$soundId",
            "raw",
            context.packageName
        )
    }
