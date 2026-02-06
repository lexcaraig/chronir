package com.cyclealarm.feature.alarmdetail

import androidx.lifecycle.ViewModel
import com.cyclealarm.data.local.AlarmEntity
import com.cyclealarm.data.repository.AlarmRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class AlarmDetailViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository
) : ViewModel() {

    private val _alarm = MutableStateFlow<AlarmEntity?>(null)
    val alarm: StateFlow<AlarmEntity?> = _alarm.asStateFlow()
}
