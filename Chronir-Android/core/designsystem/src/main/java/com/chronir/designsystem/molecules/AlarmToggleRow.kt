package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.semantics.Role
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.atoms.ChronirToggle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.theme.chronirHapticFeedback
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun AlarmToggleRow(
    title: String,
    subtitle: String,
    isEnabled: Boolean,
    onToggle: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
    badgeLabel: String? = null,
    badgeColor: Color = ColorTokens.BadgeNeutralBackground,
    enabled: Boolean = true
) {
    val haptic = chronirHapticFeedback()
    // The whole row is one toggleable node (Role.Switch): TalkBack reads "title, subtitle, switch, on"
    // and the large row is the tap target, not only the 52dp switch.
    Row(
        modifier = modifier
            .fillMaxWidth()
            .toggleable(
                value = isEnabled,
                enabled = enabled,
                role = Role.Switch,
                onValueChange = { newValue ->
                    haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                    onToggle(newValue)
                }
            )
            .padding(vertical = SpacingTokens.Medium),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            ChronirText(text = title, style = ChronirTextStyle.TitleSmall, color = MaterialTheme.colorScheme.onSurface)
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (badgeLabel != null) {
                    ChronirBadge(label = badgeLabel, containerColor = badgeColor)
                    Spacer(Modifier.width(SpacingTokens.XSmall))
                }
                ChronirText(
                    text = subtitle,
                    style = ChronirTextStyle.BodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        Spacer(Modifier.width(SpacingTokens.Medium))
        ChronirToggle(
            checked = isEnabled,
            onCheckedChange = null,
            enabled = enabled
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmToggleRowWithBadgePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmToggleRow(
            title = "Morning Workout",
            subtitle = "Every Monday at 6:30 AM",
            isEnabled = true,
            onToggle = {},
            badgeLabel = "Weekly",
            badgeColor = ColorTokens.BadgeWeeklyBackground
        )
    }
}

@ChronirThemePreview
@Composable
private fun AlarmToggleRowSimplePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmToggleRow(
            title = "Pay Rent",
            subtitle = "1st of every month",
            isEnabled = false,
            onToggle = {}
        )
    }
}

@ChronirThemePreview
@Composable
private fun AlarmToggleRowDisabledPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmToggleRow(
            title = "Pre-alarm warning",
            subtitle = "Available with Plus",
            isEnabled = false,
            onToggle = {},
            enabled = false
        )
    }
}
