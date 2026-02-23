package com.chronir.feature.paywall

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle

private enum class PlanOption(val label: String, val period: String) {
    ANNUAL("Annual", "year"),
    MONTHLY("Monthly", "month")
}

@Composable
fun PaywallScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: PaywallViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var selectedPlan by remember { mutableStateOf(PlanOption.ANNUAL) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Large),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(80.dp))

            // Header
            Icon(
                imageVector = Icons.Filled.Notifications,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(SpacingTokens.XXLarge)
            )
            Spacer(Modifier.height(SpacingTokens.Medium))
            ChronirText(
                text = "Unlock Plus",
                style = ChronirTextStyle.HeadlineTitle,
                color = MaterialTheme.colorScheme.onSurface
            )

            Spacer(Modifier.height(SpacingTokens.XLarge))

            // Feature list
            FeatureRow(icon = "∞", title = "Unlimited alarms")
            FeatureRow(icon = "⏰", title = "Custom snooze intervals")
            FeatureRow(icon = "🔔", title = "Pre-alarm warnings")
            FeatureRow(icon = "📷", title = "Photo attachments")
            FeatureRow(icon = "📊", title = "Completion history & streaks")

            Spacer(Modifier.height(SpacingTokens.XLarge))

            // Plan selector
            val annualPrice = uiState.annualPrice
            val monthlyPrice = uiState.monthlyPrice
            PlanRow(
                plan = PlanOption.ANNUAL,
                price = annualPrice,
                isSelected = selectedPlan == PlanOption.ANNUAL,
                badge = "Best Deal",
                onClick = { selectedPlan = PlanOption.ANNUAL }
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            PlanRow(
                plan = PlanOption.MONTHLY,
                price = monthlyPrice,
                isSelected = selectedPlan == PlanOption.MONTHLY,
                badge = null,
                onClick = { selectedPlan = PlanOption.MONTHLY }
            )

            Spacer(Modifier.height(SpacingTokens.Large))

            val selectedPrice = if (selectedPlan == PlanOption.ANNUAL) annualPrice else monthlyPrice

            // Renewal terms
            ChronirText(
                text = "Auto-renews at $selectedPrice/${selectedPlan.period}. " +
                    "Cancel anytime in Google Play > Subscriptions.",
                style = ChronirTextStyle.LabelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(SpacingTokens.Medium))

            // CTA Button
            ChronirButton(
                text = "Subscribe — $selectedPrice/${if (selectedPlan == PlanOption.MONTHLY) "mo" else "yr"}",
                onClick = {
                    val activity = context as? android.app.Activity ?: return@ChronirButton
                    if (selectedPlan == PlanOption.ANNUAL) {
                        viewModel.purchaseAnnual(activity)
                    } else {
                        viewModel.purchaseMonthly(activity)
                    }
                },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(SpacingTokens.Large))

            // Legal footer
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                TextButton(onClick = { viewModel.restorePurchases() }) {
                    ChronirText(
                        text = "Restore Purchases",
                        style = ChronirTextStyle.LabelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Row {
                    TextButton(onClick = {
                        val intent = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("https://gist.github.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9")
                        )
                        context.startActivity(intent)
                    }) {
                        ChronirText(
                            text = "Terms",
                            style = ChronirTextStyle.LabelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    TextButton(onClick = {
                        val intent = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("https://gist.github.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c")
                        )
                        context.startActivity(intent)
                    }) {
                        ChronirText(
                            text = "Privacy",
                            style = ChronirTextStyle.LabelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            Spacer(Modifier.height(SpacingTokens.XXLarge))
        }

        // Close button
        IconButton(
            onClick = onDismiss,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(top = SpacingTokens.XXLarge, end = SpacingTokens.Default)
        ) {
            Box(
                modifier = Modifier
                    .size(30.dp)
                    .background(
                        MaterialTheme.colorScheme.surfaceVariant,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Close,
                    contentDescription = "Close",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(14.dp)
                )
            }
        }
    }
}

@Composable
private fun FeatureRow(
    icon: String,
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
                .size(40.dp)
                .background(
                    MaterialTheme.colorScheme.primary.copy(alpha = 0.12f),
                    CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = icon,
                fontSize = 16.sp
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

@Composable
private fun PlanRow(
    plan: PlanOption,
    price: String,
    isSelected: Boolean,
    badge: String?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(RadiusTokens.Md),
        color = if (isSelected) {
            MaterialTheme.colorScheme.primary.copy(alpha = 0.08f)
        } else {
            MaterialTheme.colorScheme.surface
        },
        border = BorderStroke(
            width = if (isSelected) 2.dp else 0.5.dp,
            color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline
        )
    ) {
        Row(
            modifier = Modifier.padding(SpacingTokens.Medium),
            verticalAlignment = Alignment.CenterVertically
        ) {
            RadioButton(
                selected = isSelected,
                onClick = onClick,
                colors = RadioButtonDefaults.colors(
                    selectedColor = MaterialTheme.colorScheme.primary
                )
            )
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirText(
                text = plan.label,
                style = ChronirTextStyle.BodyLarge,
                color = MaterialTheme.colorScheme.onSurface
            )
            if (badge != null) {
                Spacer(Modifier.width(SpacingTokens.Small))
                ChronirBadge(
                    label = badge,
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = MaterialTheme.colorScheme.onPrimary
                )
            }
            Spacer(Modifier.weight(1f))
            ChronirText(
                text = price,
                style = ChronirTextStyle.TitleMedium,
                color = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun PaywallScreenPreview() {
    PaywallScreen(onDismiss = {})
}
