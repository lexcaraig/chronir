package com.chronir.feature.settings

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.SettingsNavigationRow
import com.chronir.designsystem.molecules.SettingsSection
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.services.SubscriptionTier

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SubscriptionScreen(
    onBack: () -> Unit,
    onNavigateToPaywall: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: SubscriptionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Subscription") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        modifier = modifier
    ) { innerPadding ->
        SubscriptionContent(
            tier = uiState.tier,
            onUpgrade = onNavigateToPaywall,
            onManage = {
                context.startActivity(
                    Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/account/subscriptions"))
                )
            },
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(SpacingTokens.Default)
        )
    }
}

@Composable
private fun SubscriptionContent(
    tier: SubscriptionTier,
    onUpgrade: () -> Unit,
    onManage: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
    ) {
        SettingsSection(header = "Current Plan") {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Medium),
                verticalAlignment = Alignment.CenterVertically
            ) {
                ChronirText(
                    text = if (tier == SubscriptionTier.PLUS) "Plus" else "Free",
                    style = ChronirTextStyle.TitleMedium
                )
                if (tier == SubscriptionTier.PLUS) {
                    Spacer(Modifier.width(SpacingTokens.Small))
                    ChronirBadge(
                        label = "Active",
                        containerColor = ColorTokens.BadgeSuccessBackground,
                        contentColor = ColorTokens.BadgeSuccessForeground
                    )
                }
            }
        }

        SettingsSection(header = "Plan Comparison") {
            FeatureComparisonHeader()
            FeatureComparisonRow("Alarms", freeValue = "3", plusValue = "Unlimited")
            FeatureComparisonRow("Pre-alarm warnings", freeValue = "Up to 30 min", plusValue = "Up to 1 week")
            FeatureComparisonRow("Custom snooze", freeValue = null, plusValue = null)
            FeatureComparisonRow("Alarm notes", freeValue = null, plusValue = null)
            FeatureComparisonRow("Completion history", freeValue = null, plusValue = null)
            FeatureComparisonRow("Streaks", freeValue = null, plusValue = null)
        }

        if (tier == SubscriptionTier.FREE) {
            ChronirButton(
                text = "Upgrade to Plus",
                onClick = onUpgrade,
                modifier = Modifier.fillMaxWidth()
            )
        } else {
            SettingsNavigationRow(
                title = "Manage Subscription",
                value = "Google Play",
                onClick = onManage
            )
        }
    }
}

@Composable
private fun FeatureComparisonHeader() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = SpacingTokens.Medium, vertical = SpacingTokens.Small),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Spacer(Modifier.weight(1f))
        ChronirText(
            text = "Free",
            style = ChronirTextStyle.LabelLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(0.7f)
        )
        ChronirText(
            text = "Plus",
            style = ChronirTextStyle.LabelLarge,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(0.7f)
        )
    }
}

/** A comparison row; a null value means "not included" (Free) or "included" (Plus). */
@Composable
private fun FeatureComparisonRow(
    feature: String,
    freeValue: String?,
    plusValue: String?
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = SpacingTokens.Medium, vertical = SpacingTokens.Small)
            .semantics(mergeDescendants = true) {},
        verticalAlignment = Alignment.CenterVertically
    ) {
        ChronirText(
            text = feature,
            style = ChronirTextStyle.BodyMedium,
            modifier = Modifier.weight(1f)
        )
        Box(modifier = Modifier.weight(0.7f), contentAlignment = Alignment.CenterEnd) {
            ChronirText(
                text = freeValue ?: "\u2014",
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.End,
                modifier = if (freeValue == null) {
                    Modifier.semantics { contentDescription = "Free: not included" }
                } else {
                    Modifier.semantics { contentDescription = "Free: $freeValue" }
                }
            )
        }
        Box(modifier = Modifier.weight(0.7f), contentAlignment = Alignment.CenterEnd) {
            if (plusValue == null) {
                Icon(
                    Icons.Filled.Check,
                    contentDescription = "Plus: included",
                    tint = MaterialTheme.colorScheme.onSurface
                )
            } else {
                ChronirText(
                    text = plusValue,
                    style = ChronirTextStyle.BodyMedium,
                    textAlign = TextAlign.End,
                    modifier = Modifier.semantics { contentDescription = "Plus: $plusValue" }
                )
            }
        }
    }
}

@ChronirPreview
@Composable
private fun SubscriptionContentFreePreview() {
    ChronirTheme(dynamicColor = false) {
        Surface { SubscriptionContent(tier = SubscriptionTier.FREE, onUpgrade = {}, onManage = {}) }
    }
}

@ChronirPreview
@Composable
private fun SubscriptionContentPlusPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface { SubscriptionContent(tier = SubscriptionTier.PLUS, onUpgrade = {}, onManage = {}) }
    }
}
