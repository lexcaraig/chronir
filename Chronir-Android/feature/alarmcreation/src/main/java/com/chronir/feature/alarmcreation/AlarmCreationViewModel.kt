package com.chronir.feature.alarmcreation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.AlarmTemplate
import com.chronir.model.CycleType
import com.chronir.model.FollowUpInterval
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import com.chronir.services.AlarmScheduler
import com.chronir.services.BillingService
import com.chronir.services.DateCalculator
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
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
    val additionalTimes: List<LocalTime> = emptyList(),
    val preAlarmMinutes: Int = 0,
    val followUpInterval: FollowUpInterval = FollowUpInterval.THIRTY_MINUTES,
    val repeatInterval: Int = 1,
    val isSaving: Boolean = false,
    val saveSuccess: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class AlarmCreationViewModel
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val dateCalculator: DateCalculator,
        private val alarmScheduler: AlarmScheduler,
        private val billingService: BillingService
    ) : ViewModel() {

        companion object {
            private const val FREE_TIER_ALARM_LIMIT = 3
        }

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

        fun updatePreAlarmMinutes(minutes: Int) {
            // Extended pre-alarm offsets (>30min) require Plus
            val isFree = billingService.subscriptionState.value.tier == SubscriptionTier.FREE
            if (isFree && minutes > 30) {
                _uiState.update {
                    it.copy(errorMessage = "Extended pre-alarm offsets require Plus subscription.")
                }
                return
            }
            _uiState.update { it.copy(preAlarmMinutes = minutes) }
        }

        fun updateFollowUpInterval(interval: FollowUpInterval) {
            _uiState.update { it.copy(followUpInterval = interval) }
        }

        fun addAdditionalTime(hour: Int, minute: Int) {
            _uiState.update { state ->
                val newTime = LocalTime.of(hour, minute)
                if (state.additionalTimes.contains(newTime)) state
                else state.copy(additionalTimes = state.additionalTimes + newTime)
            }
        }

        fun removeAdditionalTime(index: Int) {
            _uiState.update { state ->
                state.copy(additionalTimes = state.additionalTimes.toMutableList().apply { removeAt(index) })
            }
        }

        fun loadTemplate(template: AlarmTemplate) {
            _uiState.update {
                it.copy(
                    title = template.name,
                    cycleType = template.cycleType,
                    hour = template.timeOfDay.hour,
                    minute = template.timeOfDay.minute,
                    persistenceLevel = template.persistenceLevel,
                    preAlarmMinutes = template.preAlarmMinutes,
                    note = template.note,
                    category = template.category,
                    selectedDays = when (val s = template.schedule) {
                        is Schedule.Weekly -> s.daysOfWeek.toSet()
                        else -> it.selectedDays
                    },
                    dayOfMonth = when (val s = template.schedule) {
                        is Schedule.MonthlyDate -> s.dayOfMonth
                        else -> it.dayOfMonth
                    },
                    annualMonth = when (val s = template.schedule) {
                        is Schedule.Annual -> s.month
                        else -> it.annualMonth
                    },
                    annualDay = when (val s = template.schedule) {
                        is Schedule.Annual -> s.dayOfMonth
                        else -> it.annualDay
                    },
                    repeatInterval = when (val s = template.schedule) {
                        is Schedule.Weekly -> s.interval
                        is Schedule.MonthlyDate -> s.interval
                        is Schedule.Annual -> s.interval
                        else -> it.repeatInterval
                    }
                )
            }
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
                    // Free tier: 3-alarm limit
                    val tier = billingService.subscriptionState.value.tier
                    if (tier == SubscriptionTier.FREE) {
                        val existingCount = alarmRepository.observeAlarms().first().size
                        if (existingCount >= FREE_TIER_ALARM_LIMIT) {
                            _uiState.update {
                                it.copy(
                                    isSaving = false,
                                    errorMessage = "Free plan is limited to $FREE_TIER_ALARM_LIMIT alarms. " +
                                        "Upgrade to Plus for unlimited alarms."
                                )
                            }
                            return@launch
                        }
                    }
                    val schedule = buildSchedule(state)
                    val timeOfDay = LocalTime.of(state.hour, state.minute)

                    val alarm = Alarm(
                        title = state.title.trim(),
                        cycleType = state.cycleType,
                        timeOfDay = timeOfDay,
                        schedule = schedule,
                        persistenceLevel = state.persistenceLevel,
                        preAlarmMinutes = state.preAlarmMinutes,
                        followUpIntervalMinutes = state.followUpInterval.minutes,
                        additionalTimesOfDay = state.additionalTimes,
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
                            errorMessage = "Failed to save alarm. Please try again."
                        )
                    }
                }
            }
        }

        private fun buildSchedule(state: AlarmCreationUiState): Schedule = when (state.cycleType) {
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
