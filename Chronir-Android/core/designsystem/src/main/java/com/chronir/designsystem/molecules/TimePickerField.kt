package com.chronir.designsystem.molecules

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun TimePickerField(
    label: String,
    timeText: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onClickLabel: String = "Change time"
) {
    Column(
        modifier = modifier
            .clickable(role = Role.Button, onClickLabel = onClickLabel, onClick = onClick)
            .padding(vertical = SpacingTokens.Default)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = timeText,
            style = MaterialTheme.typography.displayMedium
        )
    }
}

@ChronirPreview
@Composable
private fun TimePickerFieldPreview() {
    ChronirTheme(dynamicColor = false) {
        TimePickerField(
            label = "Alarm time",
            timeText = "8:30 AM",
            onClick = {},
            modifier = Modifier.padding(horizontal = SpacingTokens.Medium)
        )
    }
}
