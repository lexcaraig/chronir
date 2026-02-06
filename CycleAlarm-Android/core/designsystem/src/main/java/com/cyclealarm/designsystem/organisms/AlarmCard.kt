package com.cyclealarm.designsystem.organisms

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.atoms.CycleBadge
import com.cyclealarm.designsystem.atoms.CycleToggle
import com.cyclealarm.designsystem.tokens.SpacingTokens

@Composable
fun AlarmCard(
    title: String,
    timeText: String,
    cycleLabel: String,
    isEnabled: Boolean,
    onToggle: (Boolean) -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(SpacingTokens.Default),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = timeText,
                    style = MaterialTheme.typography.headlineMedium
                )
                CycleBadge(
                    label = cycleLabel,
                    modifier = Modifier.padding(top = SpacingTokens.XSmall)
                )
            }
            CycleToggle(
                checked = isEnabled,
                onCheckedChange = onToggle
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmCardPreview() {
    AlarmCard(
        title = "Weekly Standup",
        timeText = "09:00 AM",
        cycleLabel = "Weekly",
        isEnabled = true,
        onToggle = {},
        onClick = {}
    )
}
