package com.chronir.feature.settings

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.SettingsNavigationRow
import com.chronir.designsystem.molecules.SettingsSection
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
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
                title = { ChronirText(text = "Subscription", style = ChronirTextStyle.TitleMedium) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        },
        modifier = modifier
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(SpacingTokens.Default),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
        ) {
            // Current plan
            SettingsSection(header = "Current Plan") {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(SpacingTokens.Medium),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    ChronirText(
                        text = if (uiState.tier == SubscriptionTier.PLUS) "Plus" else "Free",
                        style = ChronirTextStyle.TitleMedium
                    )
                    if (uiState.tier == SubscriptionTier.PLUS) {
                        Spacer(Modifier.padding(start = SpacingTokens.Small))
                        ChronirBadge(
                            label = "Active",
                            containerColor = ColorTokens.Success,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
            }

            // Feature comparison
            SettingsSection(header = "Plan Comparison") {
                FeatureComparisonRow("Alarms", "3 max", "Unlimited")
                FeatureComparisonRow("Photo attachments", "—", checkmark = true)
                FeatureComparisonRow("Custom snooze", "—", checkmark = true)
                FeatureComparisonRow("Pre-alarm warnings", "—", checkmark = true)
                FeatureComparisonRow("Completion history", "—", checkmark = true)
                FeatureComparisonRow("Streaks", "—", checkmark = true)
            }

            // Actions
            if (uiState.tier == SubscriptionTier.FREE) {
                ChronirButton(
                    text = "Upgrade to Plus",
                    onClick = onNavigateToPaywall,
                    modifier = Modifier.fillMaxWidth()
                )
            } else {
                SettingsNavigationRow(
                    title = "Manage Subscription",
                    value = "Google Play",
                    onClick = {
                        val intent = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("https://play.google.com/store/account/subscriptions")
                        )
                        context.startActivity(intent)
                    }
                )
            }
        }
    }
}

@Composable
private fun FeatureComparisonRow(
    feature: String,
    freeValue: String = "",
    plusValue: String = "",
    checkmark: Boolean = false,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = SpacingTokens.Medium, vertical = SpacingTokens.Small),
        verticalAlignment = Alignment.CenterVertically
    ) {
        ChronirText(
            text = feature,
            style = ChronirTextStyle.BodyMedium,
            modifier = Modifier.weight(1f)
        )
        ChronirText(
            text = freeValue,
            style = ChronirTextStyle.BodySecondary,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.weight(0.5f)
        )
        Box(modifier = Modifier.weight(0.5f), contentAlignment = Alignment.CenterEnd) {
            if (checkmark) {
                Icon(
                    Icons.Filled.Check,
                    contentDescription = "Included",
                    tint = ColorTokens.Success,
                    modifier = Modifier.size(20.dp)
                )
            } else {
                ChronirText(
                    text = plusValue,
                    style = ChronirTextStyle.BodyMedium,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}
