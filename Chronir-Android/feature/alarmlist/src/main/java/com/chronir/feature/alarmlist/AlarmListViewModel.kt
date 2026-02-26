package com.chronir.feature.alarmlist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.CycleType
import com.chronir.services.AlarmScheduler
import com.chronir.services.NotificationCleanupService
import com.chronir.services.PendingConfirmationService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AlarmListViewModel
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val alarmScheduler: AlarmScheduler,
        private val notificationCleanupService: NotificationCleanupService,
        private val pendingConfirmationService: PendingConfirmationService
    ) : ViewModel() {

        private val _selectedCategory = MutableStateFlow<AlarmCategory?>(null)
        val selectedCategory: StateFlow<AlarmCategory?> = _selectedCategory

        val activeAlarms: StateFlow<List<Alarm>> = combine(
            alarmRepository.observeAlarms(),
            _selectedCategory
        ) { allAlarms, category ->
            val filtered = if (category == null) allAlarms
            else allAlarms.filter { AlarmCategory.fromColorTag(it.colorTag) == category }
            filtered.filter { alarm ->
                // Active: not a completed one-time alarm
                !(alarm.cycleType == CycleType.ONE_TIME && !alarm.isEnabled && alarm.lastFiredDate != null)
            }
        }.stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptyList()
        )

        val archivedAlarms: StateFlow<List<Alarm>> = combine(
            alarmRepository.observeAlarms(),
            _selectedCategory
        ) { allAlarms, category ->
            val filtered = if (category == null) allAlarms
            else allAlarms.filter { AlarmCategory.fromColorTag(it.colorTag) == category }
            filtered.filter { alarm ->
                alarm.cycleType == CycleType.ONE_TIME && !alarm.isEnabled && alarm.lastFiredDate != null
            }
        }.stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptyList()
        )

        // Keep for backward compatibility
        val alarms: StateFlow<List<Alarm>> = activeAlarms

        fun selectCategory(category: AlarmCategory?) {
            _selectedCategory.value = if (_selectedCategory.value == category) null else category
        }

        fun toggleAlarm(alarm: Alarm) {
            viewModelScope.launch {
                val updated = alarm.copy(
                    isEnabled = !alarm.isEnabled,
                    isPendingConfirmation = false,
                    pendingSince = null
                )
                alarmRepository.updateAlarm(updated)
                if (updated.isEnabled) {
                    alarmScheduler.schedule(updated)
                } else {
                    alarmScheduler.cancel(updated.id)
                    notificationCleanupService.cancelAlarmNotifications(alarm.id)
                }
            }
        }

        fun deleteAlarm(alarm: Alarm) {
            viewModelScope.launch {
                alarmScheduler.cancel(alarm.id)
                notificationCleanupService.cancelAlarmNotifications(alarm.id)
                alarmRepository.deleteAlarm(alarm.id)
            }
        }

        fun confirmPending(alarm: Alarm) {
            viewModelScope.launch {
                pendingConfirmationService.confirmDone(alarm)
            }
        }
    }
