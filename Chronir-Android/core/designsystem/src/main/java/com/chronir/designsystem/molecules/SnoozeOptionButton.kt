package com.chronir.designsystem.molecules

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun SnoozeOptionButton(
    label: String,
    sublabel: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .size(72.dp, 64.dp)
            .clip(RoundedCornerShape(RadiusTokens.Md))
            .background(ColorTokens.BackgroundTertiary)
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        ChronirText(text = label, style = ChronirTextStyle.HeadlineSmall)
        ChronirText(
            text = sublabel,
            style = ChronirTextStyle.LabelSmall,
            color = ColorTokens.TextSecondary
        )
    }
}

enum class SnoozeInterval {
    OneHour,
    OneDay,
    OneWeek
}

@Composable
fun SnoozeOptionBar(
    onSnooze: (SnoozeInterval) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
    ) {
        SnoozeOptionButton("1", "hour", onClick = { onSnooze(SnoozeInterval.OneHour) })
        SnoozeOptionButton("1", "day", onClick = { onSnooze(SnoozeInterval.OneDay) })
        SnoozeOptionButton("1", "week", onClick = { onSnooze(SnoozeInterval.OneWeek) })
    }
}

@Preview(name = "Snooze Bar — Light", showBackground = true)
@Preview(name = "Snooze Bar — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun SnoozeOptionBarPreview() {
    ChronirTheme(dynamicColor = false) {
        SnoozeOptionBar(
            onSnooze = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
