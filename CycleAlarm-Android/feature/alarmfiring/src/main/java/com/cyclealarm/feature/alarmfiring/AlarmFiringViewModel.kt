package com.cyclealarm.feature.alarmfiring

import androidx.lifecycle.ViewModel
import com.cyclealarm.data.local.AlarmEntity
import com.cyclealarm.data.repository.AlarmRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class AlarmFiringUiState(
    val alarm: AlarmEntity? = null,
    val isFiring: Boolean = true
)

@HiltViewModel
class AlarmFiringViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AlarmFiringUiState())
    val uiState: StateFlow<AlarmFiringUiState> = _uiState.asStateFlow()
}
