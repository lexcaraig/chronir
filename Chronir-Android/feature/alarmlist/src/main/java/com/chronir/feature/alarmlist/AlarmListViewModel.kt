package com.chronir.feature.alarmlist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.services.AlarmScheduler
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AlarmListViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository,
    private val alarmScheduler: AlarmScheduler
) : ViewModel() {

    private val _selectedCategory = MutableStateFlow<AlarmCategory?>(null)
    val selectedCategory: StateFlow<AlarmCategory?> = _selectedCategory

    val alarms: StateFlow<List<Alarm>> = combine(
        alarmRepository.observeAlarms(),
        _selectedCategory
    ) { allAlarms, category ->
        if (category == null) allAlarms
        else allAlarms.filter { AlarmCategory.fromColorTag(it.colorTag) == category }
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
            val updated = alarm.copy(isEnabled = !alarm.isEnabled)
            alarmRepository.updateAlarm(updated)
            if (updated.isEnabled) {
                alarmScheduler.schedule(updated)
            } else {
                alarmScheduler.cancel(updated.id)
            }
        }
    }

    fun deleteAlarm(alarm: Alarm) {
        viewModelScope.launch {
            alarmScheduler.cancel(alarm.id)
            alarmRepository.deleteAlarm(alarm.id)
        }
    }
}
