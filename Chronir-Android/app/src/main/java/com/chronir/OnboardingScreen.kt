package com.chronir

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryChargingFull
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.ScreenLockPortrait
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.chronirColors
import com.chronir.designsystem.tokens.AnimationTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.feature.settings.AlarmReliabilitySettings
import com.chronir.feature.settings.AlarmReliabilityStatus
import com.chronir.feature.settings.rememberAlarmReliabilityStatus
import com.chronir.services.BatteryOptimizationHelper
import kotlinx.coroutines.launch

private const val PAGE_COUNT = 4
private const val RELIABILITY_PAGE = 3

@Composable
fun OnboardingScreen(
    onComplete: () -> Unit,
    modifier: Modifier = Modifier
) {
    val pagerState = rememberPagerState(pageCount = { PAGE_COUNT })
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    val reliability = rememberAlarmReliabilityStatus()

    // After the notification prompt, finish only if nothing else blocks alarms; otherwise show the fixes.
    val afterNotifications: () -> Unit = {
        val status = AlarmReliabilityStatus.read(context)
        if (status.fullScreenIntentAllowed && status.ignoringBatteryOptimizations) {
            onComplete()
        } else {
            scope.launch { pagerState.animateScrollToPage(RELIABILITY_PAGE) }
        }
    }
    val notificationLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { _ -> afterNotifications() }

    HorizontalPager(
        state = pagerState,
        modifier = modifier.fillMaxSize()
    ) { page ->
        when (page) {
            0 -> OnboardingPage(
                icon = Icons.Filled.Notifications,
                headline = "Never Forget\nWhat Matters",
                body = "High-persistence alarms for the obligations that can't be missed.",
                buttonText = "Continue",
                currentPage = pagerState.currentPage,
                onButtonClick = { scope.launch { pagerState.animateScrollToPage(1) } }
            )
            1 -> OnboardingPage(
                icon = Icons.Filled.DateRange,
                headline = "Weekly,\nMonthly,\nAnnually",
                body = "Set recurring alarms on any cycle.\nRent, meds, insurance — all covered.",
                buttonText = "Continue",
                currentPage = pagerState.currentPage,
                onButtonClick = { scope.launch { pagerState.animateScrollToPage(2) } }
            )
            2 -> OnboardingPage(
                icon = Icons.Filled.Lock,
                headline = "Stay\nNotified",
                body = "Chronir needs notification access to fire alarms even when the app is closed.",
                buttonText = "Enable Alarms",
                currentPage = pagerState.currentPage,
                onButtonClick = {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        notificationLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                    } else {
                        afterNotifications()
                    }
                },
                onSkip = onComplete
            )
            else -> OnboardingPage(
                icon = Icons.Filled.CheckCircle,
                headline = "Make Alarms\nReliable",
                body = "Two system settings decide whether an alarm can wake your screen on time.",
                buttonText = "Done",
                currentPage = pagerState.currentPage,
                onButtonClick = onComplete,
                onSkip = if (reliability.fullScreenIntentAllowed && reliability.ignoringBatteryOptimizations) null else onComplete
            ) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    ReliabilityStep(
                        icon = Icons.Filled.ScreenLockPortrait,
                        title = "Full-screen alarms",
                        done = reliability.fullScreenIntentAllowed,
                        todo = "Allow, so alarms show over the lock screen",
                        onClick = { AlarmReliabilitySettings.openFullScreenIntentSettings(context) }
                    )
                }
                ReliabilityStep(
                    icon = Icons.Filled.BatteryChargingFull,
                    title = "Battery usage",
                    done = reliability.ignoringBatteryOptimizations,
                    todo = "Set to Unrestricted, so Android doesn't delay alarms",
                    onClick = { AlarmReliabilitySettings.openBatterySettings(context) }
                )
                if (remember { BatteryOptimizationHelper(context).isKnownProblematicOem }) {
                    ChronirText(
                        text = "${Build.MANUFACTURER} phones also stop background apps on their own. " +
                            "Chronir opens the maker's battery screen; allow it to run in the background there.",
                        style = ChronirTextStyle.BodySecondary,
                        color = MaterialTheme.chronirColors.textSecondary,
                        modifier = Modifier.padding(horizontal = SpacingTokens.Medium)
                    )
                }
            }
        }
    }
}

@Composable
private fun ReliabilityStep(
    icon: ImageVector,
    title: String,
    done: Boolean,
    todo: String,
    onClick: () -> Unit
) {
    ListItem(
        leadingContent = { Icon(icon, contentDescription = null) },
        headlineContent = { ChronirText(text = title, style = ChronirTextStyle.BodyPrimary) },
        supportingContent = {
            ChronirText(
                text = if (done) "Done" else "$todo. Tap to open settings.",
                style = ChronirTextStyle.BodySecondary,
                color = if (done) MaterialTheme.chronirColors.textSecondary else MaterialTheme.chronirColors.textWarning
            )
        },
        trailingContent = if (done) {
            { Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = MaterialTheme.colorScheme.primary) }
        } else {
            null
        },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        modifier = Modifier.clickable(enabled = !done, role = Role.Button, onClick = onClick)
    )
}

@Composable
private fun OnboardingPage(
    icon: ImageVector,
    headline: String,
    body: String,
    buttonText: String,
    currentPage: Int,
    onButtonClick: () -> Unit,
    modifier: Modifier = Modifier,
    onSkip: (() -> Unit)? = null,
    extraContent: @Composable ColumnScope.() -> Unit = {}
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .windowInsetsPadding(WindowInsets.safeDrawing)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = SpacingTokens.XLarge)
                .padding(top = SpacingTokens.Massive, bottom = SpacingTokens.Large)
        ) {
            ChronirText(
                text = headline,
                style = ChronirTextStyle.HeadlineLarge,
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(SpacingTokens.Medium))

            ChronirText(
                text = body,
                style = ChronirTextStyle.BodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(SpacingTokens.Medium))
            extraContent()

            Spacer(Modifier.weight(1f))

            Box(
                modifier = Modifier
                    .size(160.dp) // token-exempt: onboarding illustration size
                    .align(Alignment.CenterHorizontally)
                    .background(color = MaterialTheme.colorScheme.surfaceVariant, shape = CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(SpacingTokens.Massive)
                )
            }

            Spacer(Modifier.weight(1f))

            PillPageIndicator(
                pageCount = PAGE_COUNT,
                currentPage = currentPage,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = SpacingTokens.Large)
            )

            ChronirButton(
                text = buttonText,
                onClick = onButtonClick,
                modifier = Modifier.fillMaxWidth()
            )

            if (onSkip != null) {
                Spacer(Modifier.height(SpacingTokens.XSmall))
                TextButton(
                    onClick = onSkip,
                    modifier = Modifier.align(Alignment.CenterHorizontally)
                ) {
                    ChronirText(
                        text = "Skip for now",
                        style = ChronirTextStyle.BodySecondary,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}

@Composable
private fun PillPageIndicator(
    pageCount: Int,
    currentPage: Int,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(pageCount) { index ->
            val width by animateDpAsState(
                targetValue = if (index == currentPage) SpacingTokens.Large else SpacingTokens.XSmall,
                animationSpec = tween(durationMillis = AnimationTokens.DurationStandard),
                label = "indicator_width"
            )
            Box(
                modifier = Modifier
                    .padding(horizontal = SpacingTokens.XXSmall)
                    .width(width)
                    .height(SpacingTokens.XSmall)
                    .background(
                        color = if (index == currentPage) {
                            MaterialTheme.colorScheme.onSurface
                        } else {
                            MaterialTheme.colorScheme.outlineVariant
                        },
                        shape = RoundedCornerShape(RadiusTokens.Full)
                    )
            )
        }
    }
}

@ChronirPreview
@Composable
private fun OnboardingReliabilityPagePreview() {
    ChronirTheme(dynamicColor = false) {
        OnboardingPage(
            icon = Icons.Filled.CheckCircle,
            headline = "Make Alarms\nReliable",
            body = "Two system settings decide whether an alarm can wake your screen on time.",
            buttonText = "Done",
            currentPage = RELIABILITY_PAGE,
            onButtonClick = {},
            onSkip = {}
        ) {
            ReliabilityStep(Icons.Filled.ScreenLockPortrait, "Full-screen alarms", done = true, todo = "Allow", onClick = {})
            ReliabilityStep(Icons.Filled.BatteryChargingFull, "Battery usage", done = false, todo = "Set to Unrestricted", onClick = {})
        }
    }
}
