package com.chronir.designsystem.molecules

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.atoms.ChronirToggle
import com.chronir.designsystem.theme.ChronirTheme
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
    badgeColor: Color = ColorTokens.AccentPrimary
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.Medium),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            ChronirText(text = title, style = ChronirTextStyle.TitleSmall)
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
        ChronirToggle(
            checked = isEnabled,
            onCheckedChange = onToggle
        )
    }
}

@Preview(name = "With Badge — Light", showBackground = true)
@Preview(name = "With Badge — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun AlarmToggleRowWithBadgePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmToggleRow(
            title = "Morning Workout",
            subtitle = "Every Monday at 6:30 AM",
            isEnabled = true,
            onToggle = {},
            badgeLabel = "Weekly",
            badgeColor = ColorTokens.BadgeWeekly
        )
    }
}

@Preview(name = "Without Badge", showBackground = true)
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
