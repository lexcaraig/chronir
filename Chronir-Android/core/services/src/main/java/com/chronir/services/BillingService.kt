package com.chronir.services

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

enum class SubscriptionTier {
    FREE,
    PLUS
}

enum class BillingPlan { MONTHLY, ANNUAL }

enum class RestoreResult { RESTORED, NOTHING_TO_RESTORE, FAILED }

/**
 * Prices come only from Google Play (formatted in the buyer's currency); they stay null until
 * product details load, so the UI never shows a guessed price.
 */
data class SubscriptionState(
    val tier: SubscriptionTier = SubscriptionTier.FREE,
    val isLoading: Boolean = false,
    val monthlyPrice: String? = null,
    val annualPrice: String? = null,
    val monthlyPriceMicros: Long? = null,
    val annualPriceMicros: Long? = null,
    val priceCurrencyCode: String? = null,
    val monthlyAvailable: Boolean = false,
    val annualAvailable: Boolean = false,
    /** True when connecting to Play or loading products failed; the paywall offers a retry. */
    val productsUnavailable: Boolean = false,
    /** True once Play has answered a purchases query; before that [tier] is a placeholder, not a verdict. */
    val isTierResolved: Boolean = false
)

@Singleton
class BillingService
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) : PurchasesUpdatedListener {

        companion object {
            const val PRODUCT_MONTHLY = "chronir_plus_monthly"
            const val PRODUCT_ANNUAL = "chronir_plus_annual"
        }

        private val _subscriptionState = MutableStateFlow(SubscriptionState())
        val subscriptionState: StateFlow<SubscriptionState> = _subscriptionState.asStateFlow()

        private var billingClient: BillingClient? = null
        private var monthlyProductDetails: ProductDetails? = null
        private var annualProductDetails: ProductDetails? = null

        fun initialize() {
            _subscriptionState.value = _subscriptionState.value.copy(productsUnavailable = false)
            billingClient = BillingClient.newBuilder(context)
                .setListener(this)
                .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
                .build()

            billingClient?.startConnection(object : BillingClientStateListener {
                override fun onBillingSetupFinished(billingResult: BillingResult) {
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        queryProducts()
                        queryExistingPurchases()
                    } else {
                        _subscriptionState.value = _subscriptionState.value.copy(productsUnavailable = true)
                    }
                }

                override fun onBillingServiceDisconnected() {
                    // Will retry on next operation (see refreshProducts)
                }
            })
        }

        private fun queryProducts() {
            val productList = listOf(
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(PRODUCT_MONTHLY)
                    .setProductType(BillingClient.ProductType.SUBS)
                    .build(),
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(PRODUCT_ANNUAL)
                    .setProductType(BillingClient.ProductType.SUBS)
                    .build()
            )

            val params = QueryProductDetailsParams.newBuilder()
                .setProductList(productList)
                .build()

            billingClient?.queryProductDetailsAsync(params) { billingResult, result ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    monthlyProductDetails = result.productDetailsList.find { it.productId == PRODUCT_MONTHLY }
                    annualProductDetails = result.productDetailsList.find { it.productId == PRODUCT_ANNUAL }

                    val monthlyPhase = monthlyProductDetails?.subscriptionOfferDetails
                        ?.firstOrNull()?.pricingPhases?.pricingPhaseList?.firstOrNull()
                    val annualPhase = annualProductDetails?.subscriptionOfferDetails
                        ?.firstOrNull()?.pricingPhases?.pricingPhaseList?.firstOrNull()

                    _subscriptionState.value = _subscriptionState.value.copy(
                        monthlyPrice = monthlyPhase?.formattedPrice,
                        annualPrice = annualPhase?.formattedPrice,
                        monthlyPriceMicros = monthlyPhase?.priceAmountMicros,
                        annualPriceMicros = annualPhase?.priceAmountMicros,
                        priceCurrencyCode = annualPhase?.priceCurrencyCode ?: monthlyPhase?.priceCurrencyCode,
                        monthlyAvailable = monthlyPhase != null,
                        annualAvailable = annualPhase != null,
                        productsUnavailable = monthlyPhase == null && annualPhase == null
                    )
                } else {
                    _subscriptionState.value = _subscriptionState.value.copy(productsUnavailable = true)
                }
            }
        }

        private fun queryExistingPurchases(onComplete: (RestoreResult) -> Unit = {}) {
            val params = QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.SUBS)
                .build()

            val client = billingClient
            if (client == null || !client.isReady) {
                onComplete(RestoreResult.FAILED)
                return
            }
            client.queryPurchasesAsync(params) { billingResult, purchases ->
                if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                    onComplete(RestoreResult.FAILED)
                    return@queryPurchasesAsync
                }
                val hasActive = purchases.any {
                    it.purchaseState == Purchase.PurchaseState.PURCHASED
                }
                _subscriptionState.value = _subscriptionState.value.copy(
                    tier = if (hasActive) SubscriptionTier.PLUS else SubscriptionTier.FREE,
                    isTierResolved = true
                )
                // Acknowledge unacknowledged purchases
                purchases.filter {
                    it.purchaseState == Purchase.PurchaseState.PURCHASED && !it.isAcknowledged
                }.forEach { purchase ->
                    acknowledgePurchase(purchase)
                }
                onComplete(if (hasActive) RestoreResult.RESTORED else RestoreResult.NOTHING_TO_RESTORE)
            }
        }

        private fun acknowledgePurchase(purchase: Purchase) {
            val params = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.purchaseToken)
                .build()
            billingClient?.acknowledgePurchase(params) { /* no-op */ }
        }

        fun launchBillingFlow(activity: Activity, plan: BillingPlan): BillingResult? {
            val productDetails = when (plan) {
                BillingPlan.MONTHLY -> monthlyProductDetails
                BillingPlan.ANNUAL -> annualProductDetails
            } ?: return null

            val offerToken = productDetails.subscriptionOfferDetails?.firstOrNull()?.offerToken
                ?: return null

            val productDetailsParams = BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(productDetails)
                .setOfferToken(offerToken)
                .build()

            val billingFlowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(listOf(productDetailsParams))
                .build()

            return billingClient?.launchBillingFlow(activity, billingFlowParams)
        }

        /** Re-queries Play for active subscriptions and reports what it found. */
        fun restorePurchases(onComplete: (RestoreResult) -> Unit = {}) {
            queryExistingPurchases(onComplete)
        }

        /** Retries loading prices, reconnecting to Play first if the connection dropped. */
        fun refreshProducts() {
            val client = billingClient
            if (client != null && client.isReady) {
                _subscriptionState.value = _subscriptionState.value.copy(productsUnavailable = false)
                queryProducts()
            } else {
                destroy()
                initialize()
            }
        }

        override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
                purchases.forEach { purchase ->
                    if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                        _subscriptionState.value = _subscriptionState.value.copy(
                            tier = SubscriptionTier.PLUS,
                            isTierResolved = true
                        )
                        if (!purchase.isAcknowledged) {
                            acknowledgePurchase(purchase)
                        }
                    }
                }
            }
        }

        fun destroy() {
            billingClient?.endConnection()
            billingClient = null
        }
    }
