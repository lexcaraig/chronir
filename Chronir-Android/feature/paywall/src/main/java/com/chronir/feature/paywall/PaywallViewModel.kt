package com.chronir.feature.paywall

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class PaywallUiState(
    val isPremium: Boolean = false,
    val isLoading: Boolean = false,
    val monthlyPrice: String = "$4.99",
    val yearlyPrice: String = "$29.99"
)

@HiltViewModel
class PaywallViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(PaywallUiState())
    val uiState: StateFlow<PaywallUiState> = _uiState.asStateFlow()
}
