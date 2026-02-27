package com.chronir.feature.settings

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirIcon
import com.chronir.designsystem.atoms.ChronirIconSize
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.SettingsSection
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HowAlarmsWorkScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { ChronirText("How Alarms Work", style = ChronirTextStyle.TitleMedium) },
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
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Default)
        ) {
            SettingsSection(header = "How It Works") {
                Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
                    ChronirText(
                        text = "Chronir uses Android's AlarmManager with setAlarmClock() to schedule high-priority alarms that fire reliably, even when the device is in Do Not Disturb mode.",
                        style = ChronirTextStyle.BodySecondary,
                        color = ColorTokens.TextSecondary
                    )
                }
            }

            SettingsSection(header = "What You Control") {
                Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
                    BulletRow("Alarm title, category, and notes")
                    BulletRow("Alarm sound and vibration")
                    BulletRow("Snooze duration (in-app)")
                    BulletRow("Require Dismissal for critical alarms")
                    BulletRow("Pre-alarm warning notifications")
                    BulletRow("Repeat schedule and interval")
                }
            }

            SettingsSection(header = "What Android Controls") {
                Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
                    BulletRow("Notification display and grouping")
                    BulletRow("Battery optimization (can delay or block alarms)")
                    BulletRow("OEM-specific power management restrictions")
                    BulletRow("Exact alarm permission (Android 12+)")
                    BulletRow("Notification title truncation (~40 characters)")
                }
            }

            SettingsSection(header = "Tips") {
                Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
                    TipRow(
                        icon = Icons.Default.Warning,
                        text = "Disable battery optimization for Chronir in Settings to ensure alarms always fire on time"
                    )
                    Spacer(Modifier.height(SpacingTokens.Small))
                    TipRow(
                        icon = Icons.Default.Info,
                        text = "Keep alarm titles under 32 characters to avoid truncation in notifications"
                    )
                    Spacer(Modifier.height(SpacingTokens.Small))
                    TipRow(
                        icon = Icons.Default.Lock,
                        text = "Use Require Dismissal for critical alarms \u2014 the alarm will keep re-alerting after snooze until you manually stop it"
                    )
                    Spacer(Modifier.height(SpacingTokens.Small))
                    TipRow(
                        icon = Icons.Default.Notifications,
                        text = "Enable pre-alarm warnings to get a heads-up notification before important alarms"
                    )
                }
            }

            Spacer(Modifier.height(SpacingTokens.XXLarge))
        }
    }
}

@Composable
private fun BulletRow(text: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.XXSmall),
        verticalAlignment = Alignment.Top
    ) {
        ChronirText(
            text = "\u2022",
            style = ChronirTextStyle.BodySecondary,
            color = ColorTokens.TextSecondary
        )
        Spacer(Modifier.width(SpacingTokens.Small))
        ChronirText(
            text = text,
            style = ChronirTextStyle.BodySecondary,
            color = ColorTokens.TextSecondary
        )
    }
}

@Composable
private fun TipRow(icon: ImageVector, text: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top
    ) {
        ChronirIcon(
            imageVector = icon,
            contentDescription = null,
            size = ChronirIconSize.Small,
            tint = ColorTokens.Primary
        )
        Spacer(Modifier.width(SpacingTokens.Small))
        ChronirText(
            text = text,
            style = ChronirTextStyle.BodySecondary,
            color = ColorTokens.TextSecondary
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun HowAlarmsWorkScreenPreview() {
    HowAlarmsWorkScreen(onBack = {})
}
