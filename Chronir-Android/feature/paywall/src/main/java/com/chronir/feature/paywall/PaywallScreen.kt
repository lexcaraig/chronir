package com.chronir.feature.paywall

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AllInclusive
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Insights
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Snooze
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirButtonStyle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.services.BillingPlan
import com.chronir.services.SubscriptionTier

private const val TERMS_URL = "https://gist.github.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9"
private const val PRIVACY_URL = "https://gist.github.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c"
private const val PLAY_SUBSCRIPTIONS_URL = "https://play.google.com/store/account/subscriptions"

private enum class PlanOption(
    val label: String,
    val period: String,
    val plan: BillingPlan
) {
    ANNUAL("Annual", "year", BillingPlan.ANNUAL),
    MONTHLY("Monthly", "month", BillingPlan.MONTHLY)
}

@Composable
fun PaywallScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: PaywallViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(uiState.message) {
        val message = uiState.message ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message, withDismissAction = true)
        viewModel.messageShown()
    }

    PaywallContent(
        uiState = uiState,
        snackbarHostState = snackbarHostState,
        onDismiss = onDismiss,
        onPurchase = { plan ->
            (context as? Activity)?.let { viewModel.purchase(it, plan) }
        },
        onRestore = viewModel::restorePurchases,
        onRetryPrices = viewModel::retryLoadingPrices,
        onOpenUrl = { url -> context.openUrl(url) },
        modifier = modifier
    )
}

@Composable
private fun PaywallContent(
    uiState: PaywallUiState,
    snackbarHostState: SnackbarHostState,
    onDismiss: () -> Unit,
    onPurchase: (BillingPlan) -> Unit,
    onRestore: () -> Unit,
    onRetryPrices: () -> Unit,
    onOpenUrl: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedPlan by rememberSaveable { mutableStateOf(PlanOption.ANNUAL) }
    val isPlus = uiState.tier != SubscriptionTier.FREE
    val selectedPrice = if (selectedPlan == PlanOption.ANNUAL) uiState.annualPrice else uiState.monthlyPrice

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackbarHostState) },
        bottomBar = {
            // CTA and renewal disclosure stay pinned so they're visible at any text size.
            if (!isPlus) {
                PaywallBottomBar(
                    selectedPlan = selectedPlan,
                    selectedPrice = selectedPrice,
                    isRestoring = uiState.isRestoring,
                    onPurchase = { onPurchase(selectedPlan.plan) },
                    onRestore = onRestore,
                    onOpenUrl = onOpenUrl
                )
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Large),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Filled.Close, contentDescription = "Close")
                }
            }

            if (isPlus) {
                PlusActiveContent(onManage = { onOpenUrl(PLAY_SUBSCRIPTIONS_URL) }, onDone = onDismiss)
                return@Column
            }

            Icon(
                imageVector = Icons.Filled.Notifications,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.size(SpacingTokens.XXLarge)
            )
            Spacer(Modifier.height(SpacingTokens.Medium))
            ChronirText(
                text = "Unlock Plus",
                style = ChronirTextStyle.HeadlineTitle,
                color = MaterialTheme.colorScheme.onSurface
            )

            Spacer(Modifier.height(SpacingTokens.XLarge))

            FeatureRow(icon = Icons.Filled.AllInclusive, title = "Unlimited alarms")
            FeatureRow(icon = Icons.Filled.Snooze, title = "Custom snooze intervals")
            FeatureRow(icon = Icons.Filled.NotificationsActive, title = "Pre-alarm warnings up to a week ahead")
            FeatureRow(icon = Icons.Filled.Insights, title = "Completion history & streaks")

            Spacer(Modifier.height(SpacingTokens.XLarge))

            when {
                uiState.pricesLoaded -> Column(
                    modifier = Modifier.selectableGroup(),
                    verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
                ) {
                    PlanRow(
                        plan = PlanOption.ANNUAL,
                        price = uiState.annualPrice,
                        detail = uiState.annualSavingsText,
                        isSelected = selectedPlan == PlanOption.ANNUAL,
                        badge = "Best value",
                        onClick = { selectedPlan = PlanOption.ANNUAL }
                    )
                    PlanRow(
                        plan = PlanOption.MONTHLY,
                        price = uiState.monthlyPrice,
                        detail = null,
                        isSelected = selectedPlan == PlanOption.MONTHLY,
                        badge = null,
                        onClick = { selectedPlan = PlanOption.MONTHLY }
                    )
                }
                uiState.pricesUnavailable -> Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    ChronirText(
                        text = "Prices couldn't load from Google Play. Check your connection.",
                        style = ChronirTextStyle.BodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    TextButton(onClick = onRetryPrices) { ChronirText(text = "Try again") }
                }
                else -> Row(verticalAlignment = Alignment.CenterVertically) {
                    CircularProgressIndicator(modifier = Modifier.size(SpacingTokens.Large))
                    Spacer(Modifier.width(SpacingTokens.Small))
                    ChronirText(
                        text = "Loading prices from Google Play",
                        style = ChronirTextStyle.BodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Spacer(Modifier.height(SpacingTokens.Large))
        }
    }
}

@Composable
private fun PaywallBottomBar(
    selectedPlan: PlanOption,
    selectedPrice: String?,
    isRestoring: Boolean,
    onPurchase: () -> Unit,
    onRestore: () -> Unit,
    onOpenUrl: (String) -> Unit
) {
    Surface(tonalElevation = SpacingTokens.XXSmall) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = SpacingTokens.Large, vertical = SpacingTokens.Small),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (selectedPrice != null) {
                ChronirText(
                    text = "Auto-renews at $selectedPrice/${selectedPlan.period}. " +
                        "Cancel anytime in Google Play > Subscriptions.",
                    style = ChronirTextStyle.BodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(Modifier.height(SpacingTokens.Small))
            }
            ChronirButton(
                text = if (selectedPrice != null) "Subscribe for $selectedPrice/${selectedPlan.period}" else "Subscribe",
                onClick = onPurchase,
                enabled = selectedPrice != null,
                modifier = Modifier.fillMaxWidth()
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(onClick = onRestore, enabled = !isRestoring) {
                    ChronirText(
                        text = if (isRestoring) "Restoring…" else "Restore Purchases",
                        style = ChronirTextStyle.LabelLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Row {
                    TextButton(onClick = { onOpenUrl(TERMS_URL) }) {
                        ChronirText(
                            text = "Terms",
                            style = ChronirTextStyle.LabelLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    TextButton(onClick = { onOpenUrl(PRIVACY_URL) }) {
                        ChronirText(
                            text = "Privacy",
                            style = ChronirTextStyle.LabelLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun PlusActiveContent(onManage: () -> Unit, onDone: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(SpacingTokens.XLarge))
        Icon(
            imageVector = Icons.Filled.CheckCircle,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.size(SpacingTokens.XXLarge)
        )
        Spacer(Modifier.height(SpacingTokens.Medium))
        ChronirText(text = "You're on Plus", style = ChronirTextStyle.HeadlineTitle)
        Spacer(Modifier.height(SpacingTokens.XSmall))
        ChronirText(
            text = "Every Plus feature is unlocked on this device.",
            style = ChronirTextStyle.BodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(SpacingTokens.XLarge))
        ChronirButton(text = "Done", onClick = onDone, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(SpacingTokens.Small))
        ChronirButton(
            text = "Manage in Google Play",
            onClick = onManage,
            style = ChronirButtonStyle.Ghost,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

@Composable
private fun FeatureRow(
    icon: ImageVector,
    title: String,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.Small),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(SpacingTokens.TouchMinTarget)
                .background(MaterialTheme.colorScheme.secondaryContainer, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null, // decorative: the title beside it names the feature
                tint = MaterialTheme.colorScheme.onSecondaryContainer,
                modifier = Modifier.size(SpacingTokens.Large)
            )
        }
        Spacer(Modifier.width(SpacingTokens.Medium))
        ChronirText(
            text = title,
            style = ChronirTextStyle.BodyLarge,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

/** One focus stop per plan: the whole row is the radio button (RadioButton draws only). */
@Composable
private fun PlanRow(
    plan: PlanOption,
    price: String?,
    detail: String?,
    isSelected: Boolean,
    badge: String?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .selectable(selected = isSelected, enabled = price != null, role = Role.RadioButton, onClick = onClick),
        shape = RoundedCornerShape(RadiusTokens.Md),
        color = if (isSelected) MaterialTheme.colorScheme.secondaryContainer else MaterialTheme.colorScheme.surface,
        border = BorderStroke(
            width = if (isSelected) 2.dp else 1.dp, // token-exempt: selection outline weights
            color = if (isSelected) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.outline
        )
    ) {
        Row(
            modifier = Modifier.padding(SpacingTokens.Medium),
            verticalAlignment = Alignment.CenterVertically
        ) {
            RadioButton(selected = isSelected, onClick = null)
            Spacer(Modifier.width(SpacingTokens.Small))
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    ChronirText(text = plan.label, style = ChronirTextStyle.BodyLarge)
                    if (badge != null) {
                        Spacer(Modifier.width(SpacingTokens.Small))
                        ChronirBadge(
                            label = badge,
                            containerColor = MaterialTheme.colorScheme.primary,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
                if (detail != null) {
                    ChronirText(
                        text = detail,
                        style = ChronirTextStyle.BodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            ChronirText(
                text = price?.let { "$it/${plan.period}" } ?: "Unavailable",
                style = ChronirTextStyle.TitleMedium
            )
        }
    }
}

private fun Context.openUrl(url: String) {
    runCatching { startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) }
}

@ChronirPreview
@Composable
private fun PaywallLoadedPreview() {
    ChronirTheme(dynamicColor = false) {
        PaywallContent(
            uiState = PaywallUiState(
                monthlyPrice = "$1.99",
                annualPrice = "$19.99",
                annualSavingsText = "≈ $1.67/mo · Save 16%"
            ),
            snackbarHostState = remember { SnackbarHostState() },
            onDismiss = {},
            onPurchase = {},
            onRestore = {},
            onRetryPrices = {},
            onOpenUrl = {}
        )
    }
}

@ChronirPreview
@Composable
private fun PaywallLoadingPreview() {
    ChronirTheme(dynamicColor = false) {
        PaywallContent(
            uiState = PaywallUiState(),
            snackbarHostState = remember { SnackbarHostState() },
            onDismiss = {},
            onPurchase = {},
            onRestore = {},
            onRetryPrices = {},
            onOpenUrl = {}
        )
    }
}

@ChronirPreview
@Composable
private fun PaywallPlusPreview() {
    ChronirTheme(dynamicColor = false) {
        PaywallContent(
            uiState = PaywallUiState(tier = SubscriptionTier.PLUS),
            snackbarHostState = remember { SnackbarHostState() },
            onDismiss = {},
            onPurchase = {},
            onRestore = {},
            onRetryPrices = {},
            onOpenUrl = {}
        )
    }
}
