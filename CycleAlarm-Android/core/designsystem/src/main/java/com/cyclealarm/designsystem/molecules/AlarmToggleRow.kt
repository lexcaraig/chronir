package com.cyclealarm.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.atoms.CycleToggle

@Composable
fun AlarmToggleRow(
    title: String,
    isEnabled: Boolean,
    onToggle: (Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium
        )
        CycleToggle(
            checked = isEnabled,
            onCheckedChange = onToggle
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmToggleRowPreview() {
    AlarmToggleRow(
        title = "Weekly Standup Reminder",
        isEnabled = true,
        onToggle = {}
    )
}
