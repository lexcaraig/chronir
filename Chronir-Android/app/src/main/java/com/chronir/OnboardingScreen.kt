package com.chronir

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
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
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.AnimationTokens
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

    HorizontalPager(
        state = pagerState,
        modifier = modifier.fillMaxSize()
    ) { page ->
        when (page) {
            0 -> OnboardingPage(
                icon = Icons.Filled.Notifications,
                iconColor = ColorTokens.Amber500,
                accentColor = ColorTokens.Amber500,
                headline = "Never Forget\nWhat Matters",
                body = "High-persistence alarms for the obligations that can't be missed.",
                buttonText = "Continue",
                currentPage = pagerState.currentPage,
                onButtonClick = {
                    scope.launch { pagerState.animateScrollToPage(1) }
                }
            )
            1 -> OnboardingPage(
                icon = Icons.Filled.DateRange,
                iconColor = ColorTokens.Success,
                accentColor = ColorTokens.Success,
                headline = "Weekly,\nMonthly,\nAnnually",
                body = "Set recurring alarms on any cycle.\nRent, meds, insurance — all covered.",
                buttonText = "Continue",
                currentPage = pagerState.currentPage,
                onButtonClick = {
                    scope.launch { pagerState.animateScrollToPage(2) }
                }
            )
            2 -> OnboardingPage(
                icon = Icons.Filled.Lock,
                iconColor = MaterialTheme.colorScheme.onSurface,
                accentColor = null,
                headline = "Stay\nNotified",
                body = "Chronir needs notification access to fire alarms even when the app is closed.",
                buttonText = "Enable Alarms",
                currentPage = pagerState.currentPage,
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
}

@Composable
private fun OnboardingPage(
    icon: ImageVector,
    iconColor: Color,
    accentColor: Color?,
    headline: String,
    body: String,
    buttonText: String,
    currentPage: Int,
    onButtonClick: () -> Unit,
    showSkip: Boolean = false,
    onSkip: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val backgroundBrush = if (accentColor != null) {
        Brush.verticalGradient(
            colors = listOf(
                accentColor.copy(alpha = 0.10f),
                Color.Transparent
            )
        )
    } else {
        Brush.verticalGradient(
            colors = listOf(Color.Transparent, Color.Transparent)
        )
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .background(backgroundBrush)
    ) {
        // Skip button — top right, page 3 only
        if (showSkip && onSkip != null) {
            TextButton(
                onClick = onSkip,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = SpacingTokens.Medium, end = SpacingTokens.Small)
            ) {
                ChronirText(
                    text = "Skip",
                    style = ChronirTextStyle.BodySecondary,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = SpacingTokens.XLarge)
                .padding(top = 80.dp, bottom = SpacingTokens.XLarge)
        ) {
            // Headline
            ChronirText(
                text = headline,
                style = ChronirTextStyle.HeadlineLarge,
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(SpacingTokens.Medium))

            // Body
            ChronirText(
                text = body,
                style = ChronirTextStyle.BodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.weight(1f))

            // Decorative icon circle
            Box(
                modifier = Modifier
                    .size(200.dp)
                    .align(Alignment.CenterHorizontally)
                    .background(
                        color = iconColor.copy(alpha = 0.10f),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = iconColor,
                    modifier = Modifier.size(96.dp)
                )
            }

            Spacer(Modifier.weight(1f))

            // Page indicator
            PillPageIndicator(
                pageCount = 3,
                currentPage = currentPage,
                activeColor = accentColor ?: MaterialTheme.colorScheme.onSurface,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = SpacingTokens.Large)
            )

            // CTA button
            ChronirButton(
                text = buttonText,
                onClick = onButtonClick,
                modifier = Modifier.fillMaxWidth()
            )

            if (showSkip && onSkip != null) {
                Spacer(Modifier.height(SpacingTokens.Small))
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
    activeColor: Color,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(pageCount) { index ->
            val width by animateDpAsState(
                targetValue = if (index == currentPage) 24.dp else 8.dp,
                animationSpec = tween(durationMillis = AnimationTokens.DurationStandard),
                label = "indicator_width"
            )
            Box(
                modifier = Modifier
                    .padding(horizontal = SpacingTokens.XXSmall)
                    .width(width)
                    .height(8.dp)
                    .background(
                        color = if (index == currentPage) activeColor
                        else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                        shape = RoundedCornerShape(4.dp)
                    )
            )
        }
    }
}
