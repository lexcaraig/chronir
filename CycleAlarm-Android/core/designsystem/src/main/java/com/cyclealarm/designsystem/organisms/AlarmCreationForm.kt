package com.cyclealarm.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.atoms.CycleButton
import com.cyclealarm.designsystem.molecules.LabeledTextField
import com.cyclealarm.designsystem.molecules.TimePickerField
import com.cyclealarm.designsystem.tokens.SpacingTokens

@Composable
fun AlarmCreationForm(
    title: String,
    onTitleChange: (String) -> Unit,
    timeText: String,
    onTimeClick: () -> Unit,
    onSave: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(SpacingTokens.Default),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Default)
    ) {
        LabeledTextField(
            label = "Title",
            value = title,
            onValueChange = onTitleChange,
            placeholder = "Alarm name"
        )
        TimePickerField(
            label = "Time",
            timeText = timeText,
            onClick = onTimeClick
        )
        CycleButton(
            text = "Save Alarm",
            onClick = onSave,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmCreationFormPreview() {
    AlarmCreationForm(
        title = "",
        onTitleChange = {},
        timeText = "08:00 AM",
        onTimeClick = {},
        onSave = {}
    )
}
