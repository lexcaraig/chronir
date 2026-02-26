package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.CompletionRepository
import com.chronir.model.CompletionRecord
import com.chronir.services.StreakCalculator
import com.chronir.services.StreakInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

data class CompletionHistoryUiState(
    val records: List<CompletionRecord> = emptyList(),
    val streakInfo: StreakInfo = StreakInfo(0, 0, 0, 0f)
)

@HiltViewModel
class CompletionHistoryViewModel
    @Inject
    constructor(
        completionRepository: CompletionRepository,
        private val streakCalculator: StreakCalculator
    ) : ViewModel() {

        val uiState: StateFlow<CompletionHistoryUiState> = completionRepository
            .observeRecent(100)
            .map { records ->
                CompletionHistoryUiState(
                    records = records,
                    streakInfo = streakCalculator.calculateStreak(records)
                )
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = CompletionHistoryUiState()
            )
    }
