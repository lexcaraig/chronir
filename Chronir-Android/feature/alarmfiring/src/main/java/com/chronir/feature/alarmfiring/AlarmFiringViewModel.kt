package com.chronir.feature.alarmfiring

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.designsystem.molecules.SnoozeInterval
import com.chronir.model.Alarm
import com.chronir.model.CompletionAction
import com.chronir.model.CycleType
import com.chronir.services.AlarmScheduler
import com.chronir.services.BillingService
import com.chronir.services.DateCalculator
import com.chronir.services.SubscriptionTier
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
    private val dateCalculator: DateCalculator,
    private val billingService: BillingService
) : ViewModel() {

    val isCustomSnoozeAvailable: Boolean
        get() = billingService.subscriptionState.value.tier != SubscriptionTier.FREE

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

            if (alarm.schedule is com.chronir.model.Schedule.OneTime) {
                // One-time alarms get disabled after firing
                val updated = alarm.copy(
                    isEnabled = false,
                    lastFiredDate = Instant.now(),
                    snoozeCount = 0,
                    updatedAt = Instant.now()
                )
                alarmRepository.updateAlarm(updated)
                alarmScheduler.cancel(alarm.id)
            } else {
                // Recurring alarms get rescheduled
                val nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                val updated = alarm.copy(
                    nextFireDate = nextFireDate,
                    lastFiredDate = Instant.now(),
                    snoozeCount = 0,
                    updatedAt = Instant.now()
                )
                alarmRepository.updateAlarm(updated)
                alarmScheduler.schedule(updated)
            }
            _uiState.update { it.copy(isFiring = false) }
        }
    }

    fun skipOccurrence() {
        val alarm = _uiState.value.alarm ?: return
        if (alarm.cycleType == CycleType.ONE_TIME) return
        viewModelScope.launch {
            completionRepository.recordCompletion(
                alarmId = alarm.id,
                action = CompletionAction.SKIPPED
            )
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
        val snoozeMinutes = when (interval) {
            SnoozeInterval.OneHour -> 60
            SnoozeInterval.OneDay -> 24 * 60
            SnoozeInterval.OneWeek -> 7 * 24 * 60
        }
        snoozeForMinutes(snoozeMinutes)
    }

    fun snoozeCustom(minutes: Int) {
        snoozeForMinutes(minutes)
    }

    private fun snoozeForMinutes(snoozeMinutes: Int) {
        val alarm = _uiState.value.alarm ?: return
        val snoozeMillis = snoozeMinutes.toLong() * 60 * 1000
        viewModelScope.launch {
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
