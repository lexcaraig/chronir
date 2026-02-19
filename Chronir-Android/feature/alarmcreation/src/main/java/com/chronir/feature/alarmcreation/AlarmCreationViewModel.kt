package com.chronir.feature.alarmcreation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
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
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import javax.inject.Inject

data class AlarmCreationUiState(
    val title: String = "",
    val hour: Int = 8,
    val minute: Int = 0,
    val cycleType: CycleType = CycleType.WEEKLY,
    val persistenceLevel: PersistenceLevel = PersistenceLevel.NOTIFICATION_ONLY,
    val note: String = "",
    val selectedDays: Set<Int> = setOf(2),
    val dayOfMonth: Int = 1,
    val annualMonth: Int = LocalDate.now().monthValue,
    val annualDay: Int = LocalDate.now().dayOfMonth,
    val oneTimeDate: LocalDate = LocalDate.now().plusDays(1),
    val category: AlarmCategory? = null,
    val preAlarmEnabled: Boolean = false,
    val repeatInterval: Int = 1,
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
        if (title.length <= 60) {
            _uiState.update { it.copy(title = title) }
        }
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
        if (note.length <= 500) {
            _uiState.update { it.copy(note = note) }
        }
    }

    fun toggleDay(day: Int) {
        _uiState.update { state ->
            val newDays = if (state.selectedDays.contains(day)) {
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

    fun updateAnnualMonth(month: Int) {
        _uiState.update { it.copy(annualMonth = month.coerceIn(1, 12)) }
    }

    fun updateAnnualDay(day: Int) {
        _uiState.update { it.copy(annualDay = day.coerceIn(1, 31)) }
    }

    fun updateOneTimeDate(date: LocalDate) {
        _uiState.update { it.copy(oneTimeDate = date) }
    }

    fun updateCategory(category: AlarmCategory?) {
        _uiState.update { it.copy(category = category) }
    }

    fun updatePreAlarmEnabled(enabled: Boolean) {
        _uiState.update { it.copy(preAlarmEnabled = enabled) }
    }

    fun updateRepeatInterval(interval: Int) {
        _uiState.update { it.copy(repeatInterval = interval.coerceIn(1, 52)) }
    }

    fun togglePersistence(enabled: Boolean) {
        _uiState.update {
            it.copy(
                persistenceLevel = if (enabled) PersistenceLevel.FULL else PersistenceLevel.NOTIFICATION_ONLY
            )
        }
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
                    preAlarmMinutes = if (state.preAlarmEnabled) 1440 else 0,
                    colorTag = state.category?.colorTag,
                    iconName = state.category?.iconKey,
                    note = state.note.trim()
                )

                val nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                val alarmWithFireDate = alarm.copy(nextFireDate = nextFireDate)

                alarmRepository.saveAlarm(alarmWithFireDate)
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
            CycleType.ONE_TIME -> {
                val fireInstant = state.oneTimeDate
                    .atTime(state.hour, state.minute)
                    .atZone(ZoneId.systemDefault())
                    .toInstant()
                Schedule.OneTime(fireDate = fireInstant)
            }
            CycleType.WEEKLY -> Schedule.Weekly(
                daysOfWeek = state.selectedDays.sorted(),
                interval = state.repeatInterval
            )
            CycleType.MONTHLY_DATE -> Schedule.MonthlyDate(
                dayOfMonth = state.dayOfMonth,
                interval = state.repeatInterval
            )
            CycleType.MONTHLY_RELATIVE -> Schedule.MonthlyRelative(
                weekOfMonth = 1,
                dayOfWeek = 2,
                interval = state.repeatInterval
            )
            CycleType.ANNUAL -> Schedule.Annual(
                month = state.annualMonth,
                dayOfMonth = state.annualDay,
                interval = state.repeatInterval
            )
            CycleType.CUSTOM_DAYS -> Schedule.CustomDays(
                intervalDays = 7,
                startDate = Instant.now()
            )
        }
    }
}
