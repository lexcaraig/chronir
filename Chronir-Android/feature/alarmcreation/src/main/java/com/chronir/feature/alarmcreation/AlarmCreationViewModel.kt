package com.chronir.feature.alarmcreation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import com.chronir.services.AlarmScheduler
import com.chronir.services.DateCalculator
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalTime
import javax.inject.Inject

data class AlarmCreationUiState(
    val title: String = "",
    val hour: Int = 8,
    val minute: Int = 0,
    val cycleType: CycleType = CycleType.WEEKLY,
    val persistenceLevel: PersistenceLevel = PersistenceLevel.NOTIFICATION_ONLY,
    val note: String = "",
    val selectedDays: Set<Int> = setOf(2), // Monday (iOS convention: 2=Monday)
    val dayOfMonth: Int = 1,
    val isSaving: Boolean = false,
    val saveSuccess: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class AlarmCreationViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository,
    private val dateCalculator: DateCalculator,
    private val alarmScheduler: AlarmScheduler
) : ViewModel() {

    private val _uiState = MutableStateFlow(AlarmCreationUiState())
    val uiState: StateFlow<AlarmCreationUiState> = _uiState.asStateFlow()

    fun updateTitle(title: String) {
        _uiState.update { it.copy(title = title) }
    }

    fun updateTime(hour: Int, minute: Int) {
        _uiState.update { it.copy(hour = hour, minute = minute) }
    }

    fun updateCycleType(cycleType: CycleType) {
        _uiState.update { it.copy(cycleType = cycleType) }
    }

    fun updatePersistenceLevel(level: PersistenceLevel) {
        _uiState.update { it.copy(persistenceLevel = level) }
    }

    fun updateNote(note: String) {
        _uiState.update { it.copy(note = note) }
    }

    fun toggleDay(day: Int) {
        _uiState.update { state ->
            val newDays = if (state.selectedDays.contains(day)) {
                // Don't allow deselecting the last day
                if (state.selectedDays.size > 1) state.selectedDays - day else state.selectedDays
            } else {
                state.selectedDays + day
            }
            state.copy(selectedDays = newDays)
        }
    }

    fun updateDayOfMonth(day: Int) {
        _uiState.update { it.copy(dayOfMonth = day.coerceIn(1, 31)) }
    }

    fun saveAlarm() {
        val state = _uiState.value
        if (state.title.isBlank()) {
            _uiState.update { it.copy(errorMessage = "Title is required") }
            return
        }

        _uiState.update { it.copy(isSaving = true, errorMessage = null) }

        viewModelScope.launch {
            try {
                val schedule = buildSchedule(state)
                val timeOfDay = LocalTime.of(state.hour, state.minute)

                val alarm = Alarm(
                    title = state.title.trim(),
                    cycleType = state.cycleType,
                    timeOfDay = timeOfDay,
                    schedule = schedule,
                    persistenceLevel = state.persistenceLevel,
                    note = state.note.trim()
                )

                // Calculate the next fire date
                val nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                val alarmWithFireDate = alarm.copy(nextFireDate = nextFireDate)

                // Save to repository
                alarmRepository.saveAlarm(alarmWithFireDate)

                // Schedule the system alarm
                alarmScheduler.schedule(alarmWithFireDate)

                _uiState.update { it.copy(isSaving = false, saveSuccess = true) }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isSaving = false,
                        errorMessage = e.message ?: "Failed to save alarm"
                    )
                }
            }
        }
    }

    private fun buildSchedule(state: AlarmCreationUiState): Schedule {
        return when (state.cycleType) {
            CycleType.WEEKLY -> Schedule.Weekly(
                daysOfWeek = state.selectedDays.sorted(),
                interval = 1
            )
            CycleType.MONTHLY_DATE -> Schedule.MonthlyDate(
                dayOfMonth = state.dayOfMonth,
                interval = 1
            )
            CycleType.MONTHLY_RELATIVE -> Schedule.MonthlyRelative(
                weekOfMonth = 1,
                dayOfWeek = 2,
                interval = 1
            )
            CycleType.ANNUAL -> Schedule.Annual(
                month = 1,
                dayOfMonth = state.dayOfMonth,
                interval = 1
            )
            CycleType.CUSTOM_DAYS -> Schedule.CustomDays(
                intervalDays = 7,
                startDate = Instant.now()
            )
        }
    }
}
