package com.chronir.feature.alarmfiring

import android.app.KeyguardManager
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.data.repository.SettingsRepository
import com.chronir.data.repository.UserSettings
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.LocalChronirHapticsEnabled
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class AlarmFiringActivity : ComponentActivity() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    companion object {
        const val EXTRA_ALARM_ID = "extra_alarm_id"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setShowWhenLocked(true)
        setTurnScreenOn(true)

        val keyguardManager = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
        keyguardManager.requestDismissKeyguard(this, null)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        val alarmId = intent?.getStringExtra(EXTRA_ALARM_ID)

        setContent {
            val settings by settingsRepository.settings.collectAsStateWithLifecycle(initialValue = UserSettings())
            ChronirTheme {
                CompositionLocalProvider(LocalChronirHapticsEnabled provides settings.hapticFeedbackEnabled) {
                    Surface(modifier = Modifier.fillMaxSize()) {
                        AlarmFiringScreen(
                            alarmId = alarmId,
                            onDismissed = { stopServiceAndFinish() }
                        )
                    }
                }
            }
        }
    }

    private fun stopServiceAndFinish() {
        // Send stop action to the firing service
        val stopIntent = Intent().apply {
            setClassName(packageName, "com.chronir.services.AlarmFiringService")
            action = "com.chronir.ACTION_STOP_ALARM"
        }
        startService(stopIntent)
        finish()
    }
}
