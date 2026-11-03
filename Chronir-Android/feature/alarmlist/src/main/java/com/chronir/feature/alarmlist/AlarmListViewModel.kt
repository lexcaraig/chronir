package com.chronir.feature.alarmlist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.SettingsRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.CycleType
import com.chronir.services.AlarmScheduler
import com.chronir.services.BillingService
import com.chronir.services.NotificationCleanupService
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.shareIn
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
        private val billingService: BillingService,
        settingsRepository: SettingsRepository
    ) : ViewModel() {

        companion object {
            /** Mirrors AlarmCreationViewModel.FREE_TIER_ALARM_LIMIT, which enforces it on save. */
            const val FREE_TIER_ALARM_LIMIT = 3
        }

        // One Room observer shared by every list below.
        private val alarms = alarmRepository.observeAlarms()
            .shareIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), replay = 1)

        /** Free tier can add an alarm only while under the limit; checked before the form opens. */
        val canCreateAlarm: StateFlow<Boolean> = combine(
            alarms,
            billingService.subscriptionState
        ) { alarms, subscription ->
            subscription.tier != SubscriptionTier.FREE || alarms.size < FREE_TIER_ALARM_LIMIT
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), true)

        val groupByCategory: StateFlow<Boolean> = settingsRepository.settings
            .map { it.groupByCategory }
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

        private val _selectedCategory = MutableStateFlow<AlarmCategory?>(null)
        val selectedCategory: StateFlow<AlarmCategory?> = _selectedCategory

        val activeAlarms: StateFlow<List<Alarm>> = combine(
            alarms,
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
            alarms,
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

        /** Undo for swipe-to-delete: puts the alarm back and re-registers it if it was enabled. */
        fun restoreAlarm(alarm: Alarm) {
            viewModelScope.launch {
                alarmRepository.saveAlarm(alarm)
                if (alarm.isEnabled) runCatching { alarmScheduler.schedule(alarm) }
            }
        }
    }
