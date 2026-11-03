package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.SettingsRepository
import com.chronir.services.AlarmSoundService
import com.chronir.services.BillingService
import com.chronir.services.SoundOption
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SoundPickerViewModel
    @Inject
    constructor(
        private val settingsRepository: SettingsRepository,
        private val alarmSoundService: AlarmSoundService,
        billingService: BillingService
    ) : ViewModel() {

        val isPlusUser: StateFlow<Boolean> = billingService.subscriptionState
            .map { it.tier != SubscriptionTier.FREE }
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

        val allSounds: List<SoundOption> = alarmSoundService.allSounds

        val currentSound: StateFlow<String> = settingsRepository.settings
            .map { it.alarmSound }
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), "default")

        /** Saves [soundId] unless it's a Plus sound and the user is on Free; returns false when gated. */
        fun selectSound(soundId: String): Boolean {
            val sound = allSounds.firstOrNull { it.id == soundId } ?: return false
            if (sound.isPlusTier && !isPlusUser.value) return false
            viewModelScope.launch {
                settingsRepository.setAlarmSound(soundId)
            }
            return true
        }

        fun previewSound(soundId: String) {
            alarmSoundService.previewSound(soundId)
        }

        fun stopPreview() {
            alarmSoundService.stopPreview()
        }
    }
