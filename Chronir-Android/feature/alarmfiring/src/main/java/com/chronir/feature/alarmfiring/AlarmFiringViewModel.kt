package com.chronir.feature.alarmfiring

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.designsystem.molecules.SnoozeInterval
import com.chronir.model.Alarm
import com.chronir.model.CompletionAction
import com.chronir.services.AlarmScheduler
import com.chronir.services.DateCalculator
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

data class AlarmFiringUiState(
    val alarm: Alarm? = null,
    val isFiring: Boolean = true
)

@HiltViewModel
class AlarmFiringViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository,
    private val completionRepository: CompletionRepository,
    private val alarmScheduler: AlarmScheduler,
    private val dateCalculator: DateCalculator
) : ViewModel() {

    private val _uiState = MutableStateFlow(AlarmFiringUiState())
    val uiState: StateFlow<AlarmFiringUiState> = _uiState.asStateFlow()

    fun loadAlarm(alarmId: String) {
        viewModelScope.launch {
            val alarm = alarmRepository.getAlarmById(alarmId) ?: return@launch
            _uiState.update { it.copy(alarm = alarm) }
        }
    }

    fun dismissAlarm() {
        val alarm = _uiState.value.alarm ?: return
        viewModelScope.launch {
            // Record completion
            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.COMPLETED
            )

            // Calculate next fire date and reschedule
            val nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
            val updated = alarm.copy(
                nextFireDate = nextFireDate,
                lastFiredDate = Instant.now(),
                snoozeCount = 0,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)
            alarmScheduler.schedule(updated)
            _uiState.update { it.copy(isFiring = false) }
        }
    }

    fun snoozeAlarm(interval: SnoozeInterval) {
        val alarm = _uiState.value.alarm ?: return
        val snoozeMinutes = when (interval) {
            SnoozeInterval.OneHour -> 60
            SnoozeInterval.OneDay -> 24 * 60
            SnoozeInterval.OneWeek -> 7 * 24 * 60
        }
        val snoozeMillis = snoozeMinutes.toLong() * 60 * 1000
        viewModelScope.launch {
            // Record snooze
            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.SNOOZED,
                snoozeDurationMinutes = snoozeMinutes
            )

            val snoozedFireDate = Instant.now().plusMillis(snoozeMillis)
            val updated = alarm.copy(
                nextFireDate = snoozedFireDate,
                snoozeCount = alarm.snoozeCount + 1,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)
            alarmScheduler.schedule(updated)
            _uiState.update { it.copy(isFiring = false) }
        }
    }
}
