package com.cyclealarm.feature.sharing

import androidx.lifecycle.ViewModel
import com.cyclealarm.data.repository.GroupRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class SharedAlarmUiState(
    val groupName: String = "",
    val memberCount: Int = 0,
    val isLoading: Boolean = false
)

@HiltViewModel
class SharedAlarmViewModel @Inject constructor(
    private val groupRepository: GroupRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SharedAlarmUiState())
    val uiState: StateFlow<SharedAlarmUiState> = _uiState.asStateFlow()
}
