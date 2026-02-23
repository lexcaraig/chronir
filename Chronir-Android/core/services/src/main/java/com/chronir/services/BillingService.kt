package com.chronir.services

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.android.billingclient.api.AcknowledgePurchaseParams
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

enum class SubscriptionTier {
    FREE, PLUS
}

enum class BillingPlan { MONTHLY, ANNUAL }

data class SubscriptionState(
    val tier: SubscriptionTier = SubscriptionTier.FREE,
    val isLoading: Boolean = false,
    val monthlyPrice: String = "$1.99",
    val annualPrice: String = "$19.99",
    val monthlyAvailable: Boolean = false,
    val annualAvailable: Boolean = false
)

@Singleton
class BillingService @Inject constructor(
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
        billingClient = BillingClient.newBuilder(context)
            .setListener(this)
            .enablePendingPurchases()
            .build()

        billingClient?.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    queryProducts()
                    queryExistingPurchases()
                }
            }

            override fun onBillingServiceDisconnected() {
                // Will retry on next operation
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

        billingClient?.queryProductDetailsAsync(params) { billingResult, productDetailsList ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                monthlyProductDetails = productDetailsList.find { it.productId == PRODUCT_MONTHLY }
                annualProductDetails = productDetailsList.find { it.productId == PRODUCT_ANNUAL }

                val monthlyPrice = monthlyProductDetails?.subscriptionOfferDetails
                    ?.firstOrNull()?.pricingPhases?.pricingPhaseList?.firstOrNull()?.formattedPrice
                val annualPrice = annualProductDetails?.subscriptionOfferDetails
                    ?.firstOrNull()?.pricingPhases?.pricingPhaseList?.firstOrNull()?.formattedPrice

                _subscriptionState.value = _subscriptionState.value.copy(
                    monthlyPrice = monthlyPrice ?: "$1.99",
                    annualPrice = annualPrice ?: "$19.99",
                    monthlyAvailable = monthlyProductDetails != null,
                    annualAvailable = annualProductDetails != null
                )
            }
        }
    }

    private fun queryExistingPurchases() {
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.SUBS)
            .build()

        billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                val hasActive = purchases.any {
                    it.purchaseState == Purchase.PurchaseState.PURCHASED
                }
                _subscriptionState.value = _subscriptionState.value.copy(
                    tier = if (hasActive) SubscriptionTier.PLUS else SubscriptionTier.FREE
                )
                // Acknowledge unacknowledged purchases
                purchases.filter {
                    it.purchaseState == Purchase.PurchaseState.PURCHASED && !it.isAcknowledged
                }.forEach { purchase ->
                    acknowledgePurchase(purchase)
                }
            }
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

    fun restorePurchases() {
        queryExistingPurchases()
    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            purchases.forEach { purchase ->
                if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                    _subscriptionState.value = _subscriptionState.value.copy(
                        tier = SubscriptionTier.PLUS
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
