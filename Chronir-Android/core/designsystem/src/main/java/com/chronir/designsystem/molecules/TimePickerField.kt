package com.chronir.designsystem.molecules

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun TimePickerField(
    label: String,
    timeText: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .clickable(onClick = onClick)
            .padding(SpacingTokens.Default)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium
        )
        Text(
            text = timeText,
            style = MaterialTheme.typography.displayMedium
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun TimePickerFieldPreview() {
    TimePickerField(
        label = "Alarm Time",
        timeText = "08:30 AM",
        onClick = {}
    )
}
