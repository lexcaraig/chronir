package com.chronir.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.contentColorFor
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.takeOrElse
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

/**
 * Pill label. Pass a `ColorTokens.Badge<Role>Background` / `Badge<Role>Foreground` pair, or a
 * `MaterialTheme.colorScheme` container role. When [contentColor] is left unspecified it is derived
 * from [containerColor]: the matching M3 on-role if the container is a scheme role, otherwise
 * whichever of near-black / white has the higher contrast against it. This means a badge can never
 * fall back to white-on-amber again.
 */
@Composable
fun ChronirBadge(
    label: String,
    modifier: Modifier = Modifier,
    containerColor: Color = ColorTokens.BadgeNeutralBackground,
    contentColor: Color = Color.Unspecified
) {
    val resolvedContent = contentColor.takeOrElse { badgeContentColorFor(containerColor) }
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(RadiusTokens.Full))
            .background(containerColor)
            .padding(horizontal = SpacingTokens.Small, vertical = SpacingTokens.XSmall)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = resolvedContent
        )
    }
}

@Composable
private fun badgeContentColorFor(container: Color): Color =
    MaterialTheme.colorScheme.contentColorFor(container).takeOrElse {
        val dark = ColorTokens.Neutral1100
        val light = ColorTokens.Neutral0
        if (contrast(dark, container) >= contrast(light, container)) dark else light
    }

private fun contrast(a: Color, b: Color): Float {
    val la = a.luminance() + 0.05f
    val lb = b.luminance() + 0.05f
    return if (la > lb) la / lb else lb / la
}

@ChronirThemePreview
@Composable
private fun ChronirBadgeCyclePreview() {
    ChronirTheme(dynamicColor = false) {
        Row(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirBadge(
                label = "Weekly",
                containerColor = ColorTokens.BadgeWeeklyBackground,
                contentColor = ColorTokens.BadgeWeeklyForeground
            )
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(
                label = "Monthly",
                containerColor = ColorTokens.BadgeMonthlyBackground,
                contentColor = ColorTokens.BadgeMonthlyForeground
            )
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(
                label = "Annual",
                containerColor = ColorTokens.BadgeAnnualBackground,
                contentColor = ColorTokens.BadgeAnnualForeground
            )
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(label = "3")
        }
    }
}

@ChronirThemePreview
@Composable
private fun ChronirBadgeSemanticPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
            Row {
                ChronirBadge(
                    label = "Active",
                    containerColor = ColorTokens.BadgeSuccessBackground,
                    contentColor = ColorTokens.BadgeSuccessForeground
                )
                Spacer(Modifier.width(SpacingTokens.Small))
                ChronirBadge(
                    label = "Snoozed",
                    containerColor = ColorTokens.BadgeWarningBackground,
                    contentColor = ColorTokens.BadgeWarningForeground
                )
                Spacer(Modifier.width(SpacingTokens.Small))
                ChronirBadge(
                    label = "Missed",
                    containerColor = ColorTokens.BadgeErrorBackground,
                    contentColor = ColorTokens.BadgeErrorForeground
                )
                Spacer(Modifier.width(SpacingTokens.Small))
                ChronirBadge(
                    label = "Pending",
                    containerColor = ColorTokens.BadgePendingBackground,
                    contentColor = ColorTokens.BadgePendingForeground
                )
            }
            Spacer(Modifier.width(SpacingTokens.Small))
            Row(modifier = Modifier.padding(top = SpacingTokens.Small)) {
                // Derived content colors (no contentColor passed)
                ChronirBadge(label = "Plus", containerColor = ColorTokens.Warning)
                Spacer(Modifier.width(SpacingTokens.Small))
                ChronirBadge(label = "Home", containerColor = MaterialTheme.colorScheme.secondaryContainer)
            }
        }
    }
}
