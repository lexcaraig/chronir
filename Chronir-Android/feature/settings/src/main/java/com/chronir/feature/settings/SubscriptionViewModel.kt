package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.services.BillingService
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SubscriptionUiState(
    val tier: SubscriptionTier = SubscriptionTier.FREE
)

@HiltViewModel
class SubscriptionViewModel
    @Inject
    constructor(
        private val billingService: BillingService
    ) : ViewModel() {

        private val _uiState = MutableStateFlow(SubscriptionUiState())
        val uiState: StateFlow<SubscriptionUiState> = _uiState.asStateFlow()

        init {
            viewModelScope.launch {
                billingService.subscriptionState.collect { state ->
                    _uiState.update { it.copy(tier = state.tier) }
                }
            }
        }
    }
