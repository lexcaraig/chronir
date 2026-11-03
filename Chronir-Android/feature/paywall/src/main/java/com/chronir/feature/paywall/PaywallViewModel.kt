package com.chronir.feature.paywall

import android.app.Activity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.android.billingclient.api.BillingClient
import com.chronir.services.BillingPlan
import com.chronir.services.BillingService
import com.chronir.services.RestoreResult
import com.chronir.services.SubscriptionState
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.util.Currency
import javax.inject.Inject
import kotlin.math.roundToInt

data class PaywallUiState(
    val tier: SubscriptionTier = SubscriptionTier.FREE,
    /** Play-formatted prices; null until product details load (no hard-coded fallback). */
    val monthlyPrice: String? = null,
    val annualPrice: String? = null,
    /** e.g. "≈ $1.67/mo · Save 16%", computed from the real Play prices. */
    val annualSavingsText: String? = null,
    val pricesUnavailable: Boolean = false,
    val isRestoring: Boolean = false,
    /** One-shot feedback shown as a snackbar. */
    val message: String? = null
) {
    val pricesLoaded: Boolean get() = monthlyPrice != null || annualPrice != null
}

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
                            annualPrice = state.annualPrice,
                            annualSavingsText = annualSavingsText(state),
                            pricesUnavailable = state.productsUnavailable
                        )
                    }
                }
            }
        }

        fun purchase(activity: Activity, plan: BillingPlan) {
            val result = billingService.launchBillingFlow(activity, plan)
            if (result == null || result.responseCode != BillingClient.BillingResponseCode.OK) {
                _uiState.update { it.copy(message = "Google Play couldn't start the purchase. Try again.") }
            }
        }

        fun restorePurchases() {
            if (_uiState.value.isRestoring) return
            _uiState.update { it.copy(isRestoring = true) }
            billingService.restorePurchases { result ->
                _uiState.update {
                    it.copy(
                        isRestoring = false,
                        message = when (result) {
                            RestoreResult.RESTORED -> "Plus restored."
                            RestoreResult.NOTHING_TO_RESTORE -> "No active subscription found for this Google account."
                            RestoreResult.FAILED -> "Couldn't reach Google Play. Try again."
                        }
                    )
                }
            }
        }

        fun retryLoadingPrices() {
            billingService.refreshProducts()
        }

        fun messageShown() {
            _uiState.update { it.copy(message = null) }
        }

        private fun annualSavingsText(state: SubscriptionState): String? {
            val annual = state.annualPriceMicros ?: return null
            val monthly = state.monthlyPriceMicros ?: return null
            val code = state.priceCurrencyCode ?: return null
            if (monthly <= 0) return null
            val perMonth = runCatching {
                NumberFormat.getCurrencyInstance().apply { currency = Currency.getInstance(code) }
                    .format(annual / 12.0 / MICROS)
            }.getOrNull() ?: return null
            val savingsPercent = ((1 - annual.toDouble() / (monthly * 12)) * 100).roundToInt()
            return if (savingsPercent > 0) "≈ $perMonth/mo · Save $savingsPercent%" else "≈ $perMonth/mo"
        }

        private companion object {
            const val MICROS = 1_000_000.0
        }
    }
