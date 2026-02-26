package com.chronir.feature.paywall

import android.app.Activity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.services.BillingPlan
import com.chronir.services.BillingService
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class PaywallUiState(
    val tier: SubscriptionTier = SubscriptionTier.FREE,
    val isLoading: Boolean = false,
    val monthlyPrice: String = "$1.99",
    val annualPrice: String = "$19.99"
)

@HiltViewModel
class PaywallViewModel
    @Inject
    constructor(
        private val billingService: BillingService
    ) : ViewModel() {

        private val _uiState = MutableStateFlow(PaywallUiState())
        val uiState: StateFlow<PaywallUiState> = _uiState.asStateFlow()

        init {
            viewModelScope.launch {
                billingService.subscriptionState.collect { state ->
                    _uiState.update {
                        it.copy(
                            tier = state.tier,
                            monthlyPrice = state.monthlyPrice,
                            annualPrice = state.annualPrice
                        )
                    }
                }
            }
        }

        fun purchaseMonthly(activity: Activity) {
            billingService.launchBillingFlow(activity, BillingPlan.MONTHLY)
        }

        fun purchaseAnnual(activity: Activity) {
            billingService.launchBillingFlow(activity, BillingPlan.ANNUAL)
        }

        fun restorePurchases() {
            billingService.restorePurchases()
        }
    }
