package com.chronir.feature.alarmfiring

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.organisms.AlarmFiringView
import com.chronir.designsystem.templates.FullScreenAlarmTemplate
import com.chronir.model.CycleType

@Composable
fun AlarmFiringScreen(
    alarmId: String?,
    onDismissed: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmFiringViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showCustomSnooze by remember { mutableStateOf(false) }

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
                onDismiss = viewModel::stopAlarm,
                onSnooze = viewModel::snoozeAlarm,
                snoozeCount = alarm.snoozeCount,
                onCustomSnooze = if (viewModel.isCustomSnoozeAvailable) {
                    { showCustomSnooze = true }
                } else {
                    null
                },
                onSkip = if (alarm.cycleType != CycleType.ONE_TIME) {
                    { viewModel.skipOccurrence() }
                } else {
                    null
                }
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

    if (showCustomSnooze) {
        CustomSnoozeSheet(
            onDismiss = { showCustomSnooze = false },
            onConfirm = { minutes ->
                showCustomSnooze = false
                viewModel.snoozeCustom(minutes)
            }
        )
    }
}
