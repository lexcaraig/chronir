package com.chronir.feature.alarmcreation

import androidx.lifecycle.ViewModel
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.CycleType
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class AlarmCreationUiState(
    val title: String = "",
    val hour: Int = 8,
    val minute: Int = 0,
    val cycleType: CycleType = CycleType.WEEKLY,
    val isPersistent: Boolean = false,
    val note: String = ""
)

@HiltViewModel
class AlarmCreationViewModel @Inject constructor(
    private val alarmRepository: AlarmRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AlarmCreationUiState())
    val uiState: StateFlow<AlarmCreationUiState> = _uiState.asStateFlow()
}
