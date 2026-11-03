package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.SettingsRepository
import com.chronir.data.repository.UserSettings
import com.chronir.model.TextSizePreference
import com.chronir.model.ThemePreference
import com.chronir.services.BillingService
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel
    @Inject
    constructor(
        private val settingsRepository: SettingsRepository,
        billingService: BillingService
    ) : ViewModel() {

        val isPlusUser: StateFlow<Boolean> = billingService.subscriptionState
            .map { it.tier != SubscriptionTier.FREE }
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

        val uiState: StateFlow<UserSettings> = settingsRepository.settings
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), UserSettings())

        fun setThemePreference(theme: ThemePreference) {
            viewModelScope.launch { settingsRepository.setThemePreference(theme) }
        }

        fun setTextSizePreference(size: TextSizePreference) {
            viewModelScope.launch { settingsRepository.setTextSizePreference(size) }
        }

        fun setGroupByCategory(enabled: Boolean) {
            viewModelScope.launch { settingsRepository.setGroupByCategory(enabled) }
        }

        fun setHapticFeedback(enabled: Boolean) {
            viewModelScope.launch { settingsRepository.setHapticFeedback(enabled) }
        }
    }
