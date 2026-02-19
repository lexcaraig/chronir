package com.chronir

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import kotlinx.coroutines.launch

@Composable
fun OnboardingScreen(
    onComplete: () -> Unit,
    modifier: Modifier = Modifier
) {
    val pagerState = rememberPagerState(pageCount = { 3 })
    val scope = rememberCoroutineScope()

    val notificationLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { _ ->
        onComplete()
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.weight(1f)
        ) { page ->
            when (page) {
                0 -> OnboardingPage(
                    icon = Icons.Filled.Notifications,
                    iconColor = MaterialTheme.colorScheme.primary,
                    title = "Never Forget\nWhat Matters",
                    subtitle = "High-persistence alarms for the obligations\nthat can't be missed.",
                    buttonText = "Continue",
                    onButtonClick = {
                        scope.launch { pagerState.animateScrollToPage(1) }
                    }
                )
                1 -> OnboardingPage(
                    icon = Icons.Filled.DateRange,
                    iconColor = ColorTokens.Warning,
                    title = "Weekly, Monthly,\nAnnually",
                    subtitle = "Set recurring alarms on any cycle.\nRent day, medication refills,\ninsurance renewals — all covered.",
                    buttonText = "Continue",
                    onButtonClick = {
                        scope.launch { pagerState.animateScrollToPage(2) }
                    }
                )
                2 -> OnboardingPage(
                    icon = Icons.Filled.Notifications,
                    iconColor = ColorTokens.Success,
                    title = "Stay Notified",
                    subtitle = "Chronir needs notification access to fire alarms\neven when the app is closed.",
                    buttonText = "Enable Alarms",
                    onButtonClick = {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            notificationLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                        } else {
                            onComplete()
                        }
                    },
                    showSkip = true,
                    onSkip = onComplete
                )
            }
        }

        // Page indicators
        PageIndicator(
            pageCount = 3,
            currentPage = pagerState.currentPage,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = SpacingTokens.XXLarge)
        )
    }
}

@Composable
private fun OnboardingPage(
    icon: ImageVector,
    iconColor: androidx.compose.ui.graphics.Color,
    title: String,
    subtitle: String,
    buttonText: String,
    onButtonClick: () -> Unit,
    showSkip: Boolean = false,
    onSkip: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = SpacingTokens.XLarge),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(Modifier.weight(1f))

        // Icon circle
        Box(
            modifier = Modifier
                .size(96.dp)
                .background(
                    color = iconColor.copy(alpha = 0.12f),
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconColor,
                modifier = Modifier.size(40.dp)
            )
        }

        Spacer(Modifier.height(SpacingTokens.Large))

        ChronirText(
            text = title,
            style = ChronirTextStyle.HeadlineTitle,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(Modifier.height(SpacingTokens.Medium))

        ChronirText(
            text = subtitle,
            style = ChronirTextStyle.BodySecondary,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(Modifier.weight(1f))

        ChronirButton(
            text = buttonText,
            onClick = onButtonClick,
            modifier = Modifier.fillMaxWidth()
        )

        if (showSkip && onSkip != null) {
            TextButton(
                onClick = onSkip,
                modifier = Modifier.padding(top = SpacingTokens.Small)
            ) {
                ChronirText(
                    text = "Skip for now",
                    style = ChronirTextStyle.BodySecondary,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Spacer(Modifier.height(SpacingTokens.Large))
    }
}

@Composable
private fun PageIndicator(
    pageCount: Int,
    currentPage: Int,
    modifier: Modifier = Modifier
) {
    androidx.compose.foundation.layout.Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(pageCount) { index ->
            Box(
                modifier = Modifier
                    .padding(horizontal = SpacingTokens.XXSmall)
                    .size(if (index == currentPage) 10.dp else 8.dp)
                    .background(
                        color = if (index == currentPage) MaterialTheme.colorScheme.primary
                        else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                        shape = CircleShape
                    )
            )
        }
    }
}
