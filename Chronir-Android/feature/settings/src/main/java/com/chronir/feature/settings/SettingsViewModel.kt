package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.SettingsRepository
import com.chronir.data.repository.UserSettings
import com.chronir.model.TextSizePreference
import com.chronir.model.ThemePreference
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    val uiState: StateFlow<UserSettings> = settingsRepository.settings
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), UserSettings())

    fun setSnoozeEnabled(enabled: Boolean) {
        viewModelScope.launch { settingsRepository.setSnoozeEnabled(enabled) }
    }

    fun setSlideToStop(enabled: Boolean) {
        viewModelScope.launch { settingsRepository.setSlideToStop(enabled) }
    }

    fun setHapticFeedback(enabled: Boolean) {
        viewModelScope.launch { settingsRepository.setHapticFeedback(enabled) }
    }

    fun setFixedTimezone(enabled: Boolean) {
        viewModelScope.launch { settingsRepository.setFixedTimezone(enabled) }
    }

    fun setThemePreference(theme: ThemePreference) {
        viewModelScope.launch { settingsRepository.setThemePreference(theme) }
    }

    fun setTextSizePreference(size: TextSizePreference) {
        viewModelScope.launch { settingsRepository.setTextSizePreference(size) }
    }

    fun setGroupByCategory(enabled: Boolean) {
        viewModelScope.launch { settingsRepository.setGroupByCategory(enabled) }
    }
}
