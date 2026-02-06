package com.cyclealarm.feature.settings

import androidx.lifecycle.ViewModel
import com.cyclealarm.data.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class SettingsUiState(
    val isDynamicColorEnabled: Boolean = true,
    val isNotificationsEnabled: Boolean = true,
    val defaultSnoozeMinutes: Int = 5,
    val isAuthenticated: Boolean = false
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()
}
