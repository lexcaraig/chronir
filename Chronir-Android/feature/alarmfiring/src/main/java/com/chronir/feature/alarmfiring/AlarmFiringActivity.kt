package com.chronir.feature.alarmfiring

import android.app.KeyguardManager
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.chronir.designsystem.theme.ChronirTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AlarmFiringActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setShowWhenLocked(true)
        setTurnScreenOn(true)

        val keyguardManager = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
        keyguardManager.requestDismissKeyguard(this, null)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        setContent {
            ChronirTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    AlarmFiringScreen()
                }
            }
        }
    }
}
