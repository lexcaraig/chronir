package com.chronir.feature.settings

import android.content.Context
import android.os.Build
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.SegmentedOptionPicker
import com.chronir.designsystem.molecules.SettingsNavigationRow
import com.chronir.designsystem.molecules.SettingsSection
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.chronirColors
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.TextSizePreference
import com.chronir.model.ThemePreference
import com.chronir.services.BatteryOptimizationHelper

// Bundled so the FAQ matches this build and opens offline.
private const val FAQ_URL = "asset:faq.md"
private const val PRIVACY_URL = "https://gist.githubusercontent.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c/raw/"
private const val TERMS_URL = "https://gist.githubusercontent.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9/raw/"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    modifier: Modifier = Modifier,
    onNavigateToHistory: () -> Unit = {},
    onNavigateToSubscription: () -> Unit = {},
    onNavigateToLegal: (title: String, url: String) -> Unit = { _, _ -> },
    onNavigateToHowAlarmsWork: () -> Unit = {},
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val isPlusUser by viewModel.isPlusUser.collectAsStateWithLifecycle()
    val reliability = rememberAlarmReliabilityStatus()
    val context = LocalContext.current
    val versionName = remember(context) { context.appVersionName() }

    SingleColumnTemplate(
        title = "Settings",
        modifier = modifier
    ) {
        Column(modifier = Modifier.padding(horizontal = SpacingTokens.Default)) {
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
                    subtitle = "Show the alarm list in one section per category",
                    isEnabled = uiState.groupByCategory,
                    onToggle = viewModel::setGroupByCategory
                )
                AlarmToggleRow(
                    title = "Haptic Feedback",
                    subtitle = "Vibrate lightly on toggles and the hold-to-complete button",
                    isEnabled = uiState.hapticFeedbackEnabled,
                    onToggle = viewModel::setHapticFeedback
                )
            }

            AlarmReliabilitySection(
                status = reliability,
                onOpenNotifications = { AlarmReliabilitySettings.openNotificationSettings(context) },
                onOpenFullScreen = { AlarmReliabilitySettings.openFullScreenIntentSettings(context) },
                onOpenBattery = { AlarmReliabilitySettings.openBatterySettings(context) },
                onOpenExactAlarms = { AlarmReliabilitySettings.openExactAlarmSettings(context) }
            )

            SettingsSection(header = "History") {
                SettingsNavigationRow(
                    title = "Completion History",
                    value = if (isPlusUser) "View" else "Plus",
                    onClick = if (isPlusUser) onNavigateToHistory else onNavigateToSubscription
                )
            }

            SettingsSection(header = "Account") {
                SettingsNavigationRow(
                    title = "Subscription",
                    value = if (isPlusUser) "Plus" else "Free",
                    onClick = onNavigateToSubscription
                )
            }

            SettingsSection(header = "About") {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = SpacingTokens.Medium)
                ) {
                    ChronirText(text = "Version", style = ChronirTextStyle.BodyPrimary, color = MaterialTheme.colorScheme.onSurface)
                    Spacer(Modifier.weight(1f))
                    ChronirText(
                        text = versionName,
                        style = ChronirTextStyle.BodySecondary,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                SettingsNavigationRow(title = "How Alarms Work", value = "", onClick = onNavigateToHowAlarmsWork)
                SettingsNavigationRow(title = "FAQ", value = "", onClick = { onNavigateToLegal("FAQ", FAQ_URL) })
                SettingsNavigationRow(
                    title = "Privacy Policy",
                    value = "",
                    onClick = { onNavigateToLegal("Privacy Policy", PRIVACY_URL) }
                )
                SettingsNavigationRow(
                    title = "Terms of Service",
                    value = "",
                    onClick = { onNavigateToLegal("Terms of Service", TERMS_URL) }
                )
            }

            Spacer(Modifier.height(SpacingTokens.XXLarge))
        }
    }
}

@Composable
private fun AlarmReliabilitySection(
    status: AlarmReliabilityStatus,
    onOpenNotifications: () -> Unit,
    onOpenFullScreen: () -> Unit,
    onOpenBattery: () -> Unit,
    onOpenExactAlarms: () -> Unit
) {
    SettingsSection(
        header = "Alarm Reliability",
        footer = batteryGuidanceFooter(LocalContext.current)
    ) {
        PermissionStatusRow(
            title = "Notifications",
            granted = status.notificationsEnabled,
            deniedText = "Off. Alarms can't alert you.",
            onClick = onOpenNotifications
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            PermissionStatusRow(
                title = "Full-screen alarms",
                granted = status.fullScreenIntentAllowed,
                deniedText = "Off. Alarms won't take over the lock screen.",
                onClick = onOpenFullScreen
            )
        }
        PermissionStatusRow(
            title = "Battery optimization",
            granted = status.ignoringBatteryOptimizations,
            grantedText = "Unrestricted",
            deniedText = "Optimized. Alarms may be delayed. Set Battery to Unrestricted.",
            onClick = onOpenBattery
        )
        // With USE_EXACT_ALARM (Android 13+) this is always granted; only show it when it isn't.
        if (!status.exactAlarmsAllowed) {
            PermissionStatusRow(
                title = "Alarms & reminders",
                granted = false,
                deniedText = "Off. Alarms can't fire at the exact time.",
                onClick = onOpenExactAlarms
            )
        }
    }
}

@Composable
private fun PermissionStatusRow(
    title: String,
    granted: Boolean,
    deniedText: String,
    onClick: () -> Unit,
    grantedText: String = "Allowed"
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = SpacingTokens.TouchMinTarget)
            .clickable(role = Role.Button, onClickLabel = "Open system settings", onClick = onClick)
            .padding(vertical = SpacingTokens.Medium),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            ChronirText(text = title, style = ChronirTextStyle.BodyPrimary, color = MaterialTheme.colorScheme.onSurface)
            ChronirText(
                text = if (granted) grantedText else "$deniedText Tap to fix.",
                style = ChronirTextStyle.BodySecondary,
                color = if (granted) MaterialTheme.chronirColors.textSecondary else MaterialTheme.chronirColors.textError
            )
        }
        Spacer(Modifier.width(SpacingTokens.Medium))
        Icon(
            imageVector = if (granted) Icons.Filled.CheckCircle else Icons.Filled.ErrorOutline,
            contentDescription = null, // the supporting text states the status
            tint = if (granted) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
        )
    }
}

private fun Context.appVersionName(): String =
    runCatching { packageManager.getPackageInfo(packageName, 0).versionName }.getOrNull() ?: ""

/** One line of OEM-specific guidance on makers known to kill background apps; generic advice elsewhere. */
private fun batteryGuidanceFooter(context: Context): String {
    val helper = BatteryOptimizationHelper(context)
    if (!helper.isKnownProblematicOem) return "Set Chronir's battery usage to Unrestricted so alarms fire on time."
    return when (helper.manufacturer) {
        "samsung" -> "Samsung: Settings > Battery > App Power Management > disable for Chronir"
        "xiaomi", "redmi" -> "Xiaomi: Settings > Battery > App battery saver > Chronir > No restrictions"
        "huawei", "honor" -> "Huawei: Settings > Battery > App launch > Chronir > Manage manually (enable all)"
        "oneplus", "oppo", "realme" -> "OnePlus/OPPO: Settings > Battery > Battery optimization > Chronir > Don't optimize"
        "vivo" -> "Vivo: Settings > Battery > Background power consumption > Chronir > enable"
        else -> "${Build.MANUFACTURER} phones often stop background apps. Set Chronir's battery usage to Unrestricted."
    }
}

@ChronirPreview
@Composable
private fun AlarmReliabilitySectionPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Default)) {
            AlarmReliabilitySection(
                status = AlarmReliabilityStatus(notificationsEnabled = true, ignoringBatteryOptimizations = false),
                onOpenNotifications = {},
                onOpenFullScreen = {},
                onOpenBattery = {},
                onOpenExactAlarms = {}
            )
        }
    }
}
