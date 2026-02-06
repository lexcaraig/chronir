package com.chronir.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.molecules.SnoozeOptionButton
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun AlarmFiringView(
    alarmTitle: String,
    timeText: String,
    onDismiss: () -> Unit,
    onSnooze: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(SpacingTokens.XXLarge),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = alarmTitle,
            style = MaterialTheme.typography.headlineLarge
        )
        Spacer(modifier = Modifier.height(SpacingTokens.Small))
        Text(
            text = timeText,
            style = MaterialTheme.typography.displayLarge
        )
        Spacer(modifier = Modifier.height(SpacingTokens.XXXLarge))
        ChronirButton(
            text = "Dismiss",
            onClick = onDismiss,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(SpacingTokens.Default))
        Row(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
        ) {
            SnoozeOptionButton(minutes = 5, onClick = { onSnooze(5) })
            SnoozeOptionButton(minutes = 10, onClick = { onSnooze(10) })
            SnoozeOptionButton(minutes = 15, onClick = { onSnooze(15) })
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmFiringViewPreview() {
    AlarmFiringView(
        alarmTitle = "Weekly Standup",
        timeText = "09:00 AM",
        onDismiss = {},
        onSnooze = {}
    )
}
