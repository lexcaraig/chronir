package com.chronir.designsystem.molecules

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun AlarmTimeDisplay(
    timeText: String,
    modifier: Modifier = Modifier,
    countdownText: String? = null
) {
    Column(modifier = modifier) {
        ChronirText(
            text = timeText,
            style = ChronirTextStyle.HeadlineTime
        )
        if (countdownText != null) {
            ChronirText(
                text = countdownText,
                style = ChronirTextStyle.CaptionCountdown,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Preview(name = "With Countdown — Light", showBackground = true)
@Preview(name = "With Countdown — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun AlarmTimeDisplayWithCountdownPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmTimeDisplay(
            timeText = "3:45 PM",
            countdownText = "Alarm in 6h 32m",
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@Preview(name = "Time Only", showBackground = true)
@Composable
private fun AlarmTimeDisplaySimplePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmTimeDisplay(
            timeText = "7:00 AM",
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@Preview(name = "Large Font", showBackground = true, fontScale = 2f)
@Composable
private fun AlarmTimeDisplayLargeFontPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmTimeDisplay(
            timeText = "3:45 PM",
            countdownText = "Alarm in 6h 32m",
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
