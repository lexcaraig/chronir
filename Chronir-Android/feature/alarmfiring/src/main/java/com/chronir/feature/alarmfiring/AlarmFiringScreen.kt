package com.chronir.feature.alarmfiring

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.organisms.AlarmFiringView
import com.chronir.designsystem.templates.FullScreenAlarmTemplate

@Composable
fun AlarmFiringScreen(
    alarmId: String?,
    onDismissed: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmFiringViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(alarmId) {
        alarmId?.let { viewModel.loadAlarm(it) }
    }

    LaunchedEffect(uiState.isFiring) {
        if (!uiState.isFiring) {
            onDismissed()
        }
    }

    FullScreenAlarmTemplate(modifier = modifier) {
        val alarm = uiState.alarm
        if (alarm != null) {
            AlarmFiringView(
                alarm = alarm,
                onDismiss = viewModel::dismissAlarm,
                onSnooze = viewModel::snoozeAlarm,
                snoozeCount = alarm.snoozeCount
            )
        } else {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
    }
}
