package com.chronir.feature.settings

import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.SegmentedOptionPicker
import com.chronir.designsystem.molecules.SettingsNavigationRow
import com.chronir.designsystem.molecules.SettingsSection
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.TextSizePreference
import com.chronir.model.ThemePreference

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    modifier: Modifier = Modifier,
    onNavigateToHistory: () -> Unit = {},
    onNavigateToSoundPicker: () -> Unit = {},
    onNavigateToWallpaper: () -> Unit = {},
    onNavigateToAccount: () -> Unit = {},
    onNavigateToSubscription: () -> Unit = {},
    onNavigateToLegal: (title: String, url: String) -> Unit = { _, _ -> },
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current

    SingleColumnTemplate(
        title = "Settings",
        modifier = modifier
    ) {
        Column(
            modifier = Modifier
                .padding(horizontal = SpacingTokens.Default)
        ) {
            // Alarm Behavior
            SettingsSection(header = "Alarm Behavior") {
                AlarmToggleRow(
                    title = "Snooze Enabled",
                    subtitle = "Allow snoozing when alarm fires",
                    isEnabled = uiState.snoozeEnabled,
                    onToggle = viewModel::setSnoozeEnabled
                )
                AlarmToggleRow(
                    title = "Slide to Stop",
                    subtitle = "Require slide gesture to dismiss",
                    isEnabled = uiState.slideToStopEnabled,
                    onToggle = viewModel::setSlideToStop
                )
                AlarmToggleRow(
                    title = "Haptic Feedback",
                    subtitle = "Vibrate on interactions",
                    isEnabled = uiState.hapticFeedbackEnabled,
                    onToggle = viewModel::setHapticFeedback
                )
                SettingsNavigationRow(
                    title = "Alarm Sound",
                    value = uiState.alarmSound.replaceFirstChar { it.uppercase() },
                    onClick = onNavigateToSoundPicker
                )
            }

            // Timezone
            SettingsSection(
                header = "Timezone",
                footer = if (uiState.fixedTimezone) {
                    "Alarms fire at the time set in their original timezone."
                } else {
                    "Alarms adjust to your current timezone."
                }
            ) {
                AlarmToggleRow(
                    title = "Fixed Timezone",
                    subtitle = "Lock alarms to their creation timezone",
                    isEnabled = uiState.fixedTimezone,
                    onToggle = viewModel::setFixedTimezone
                )
            }

            // Appearance
            SettingsSection(header = "Appearance") {
                SegmentedOptionPicker(
                    label = "Theme",
                    options = ThemePreference.entries.toList(),
                    selected = uiState.themePreference,
                    onSelect = viewModel::setThemePreference,
                    labelMapper = { it.displayName },
                    modifier = Modifier.padding(vertical = SpacingTokens.Small)
                )
                SegmentedOptionPicker(
                    label = "Text Size",
                    options = TextSizePreference.entries.toList(),
                    selected = uiState.textSizePreference,
                    onSelect = viewModel::setTextSizePreference,
                    labelMapper = { it.displayName },
                    modifier = Modifier.padding(vertical = SpacingTokens.Small)
                )
                AlarmToggleRow(
                    title = "Group by Category",
                    subtitle = "Organize alarms by their category",
                    isEnabled = uiState.groupByCategory,
                    onToggle = viewModel::setGroupByCategory
                )
                SettingsNavigationRow(
                    title = "Alarm Wallpaper",
                    value = "Customize",
                    onClick = onNavigateToWallpaper
                )
            }

            // Notifications
            SettingsSection(header = "Notifications") {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(SpacingTokens.Medium)
                ) {
                    ChronirText(text = "Status", style = ChronirTextStyle.BodyPrimary)
                    Spacer(Modifier.weight(1f))
                    ChronirText(
                        text = "Enabled",
                        style = ChronirTextStyle.BodySecondary,
                        color = ColorTokens.Success
                    )
                }
            }

            // Battery Optimization
            SettingsSection(
                header = "Battery & Reliability",
                footer = getBatteryGuidanceFooter()
            ) {
                SettingsNavigationRow(
                    title = "Battery Optimization",
                    value = "Open Settings",
                    onClick = {
                        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        context.startActivity(intent)
                    }
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    SettingsNavigationRow(
                        title = "Exact Alarm Permission",
                        value = "Check",
                        onClick = {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            context.startActivity(intent)
                        }
                    )
                }
            }

            // History & Streaks (Plus only)
            SettingsSection(header = "History") {
                SettingsNavigationRow(
                    title = "Completion History",
                    value = if (viewModel.isPlusUser) "View" else "Plus",
                    onClick = if (viewModel.isPlusUser) onNavigateToHistory else onNavigateToSubscription
                )
            }

            // Subscription
            SettingsSection(header = "Account") {
                SettingsNavigationRow(
                    title = "Subscription",
                    value = "Manage",
                    onClick = onNavigateToSubscription
                )
            }

            // About
            SettingsSection(header = "About") {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(SpacingTokens.Medium)
                ) {
                    ChronirText(text = "Version", style = ChronirTextStyle.BodyPrimary)
                    Spacer(Modifier.weight(1f))
                    ChronirText(
                        text = "1.0.0",
                        style = ChronirTextStyle.BodySecondary,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                SettingsNavigationRow(
                    title = "FAQ",
                    value = "",
                    onClick = {
                        onNavigateToLegal(
                            "FAQ",
                            "https://gist.github.com/lexcaraig/chronir-faq"
                        )
                    }
                )
                SettingsNavigationRow(
                    title = "Privacy Policy",
                    value = "",
                    onClick = {
                        onNavigateToLegal(
                            "Privacy Policy",
                            "https://gist.github.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c"
                        )
                    }
                )
                SettingsNavigationRow(
                    title = "Terms of Service",
                    value = "",
                    onClick = {
                        onNavigateToLegal(
                            "Terms of Service",
                            "https://gist.github.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9"
                        )
                    }
                )
            }

            Spacer(Modifier.height(SpacingTokens.XXLarge))
        }
    }
}

private fun getBatteryGuidanceFooter(): String {
    val manufacturer = Build.MANUFACTURER.lowercase()
    return when {
        manufacturer.contains("samsung") ->
            "Samsung: Settings > Battery > App Power Management > disable for Chronir"
        manufacturer.contains("xiaomi") || manufacturer.contains("redmi") ->
            "Xiaomi: Settings > Battery > App battery saver > Chronir > No restrictions"
        manufacturer.contains("huawei") || manufacturer.contains("honor") ->
            "Huawei: Settings > Battery > App launch > Chronir > Manage manually (enable all)"
        manufacturer.contains("oneplus") || manufacturer.contains("oppo") ->
            "OnePlus/OPPO: Settings > Battery > Battery optimization > Chronir > Don't optimize"
        manufacturer.contains("vivo") ->
            "Vivo: Settings > Battery > Background power consumption > Chronir > enable"
        else ->
            "Disable battery optimization for Chronir to ensure alarms fire reliably."
    }
}

@Preview(showBackground = true)
@Composable
private fun SettingsScreenPreview() {
    // Preview without ViewModel - would need a mock
    SingleColumnTemplate(title = "Settings") {
        Column(modifier = Modifier.padding(SpacingTokens.Default)) {
            SettingsSection(header = "Alarm Behavior") {
                AlarmToggleRow(
                    title = "Snooze Enabled",
                    subtitle = "Allow snoozing when alarm fires",
                    isEnabled = true,
                    onToggle = {}
                )
            }
        }
    }
}
