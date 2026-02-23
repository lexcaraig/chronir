package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.SettingsRepository
import com.chronir.services.AlarmSoundService
import com.chronir.services.SoundOption
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SoundPickerViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val alarmSoundService: AlarmSoundService
) : ViewModel() {

    val allSounds: List<SoundOption> = alarmSoundService.allSounds

    val currentSound: StateFlow<String> = settingsRepository.settings
        .map { it.alarmSound }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), "default")

    fun selectSound(soundId: String) {
        viewModelScope.launch {
            settingsRepository.setAlarmSound(soundId)
        }
    }

    fun previewSound(soundId: String) {
        alarmSoundService.previewSound(soundId)
    }

    fun stopPreview() {
        alarmSoundService.stopPreview()
    }
}
