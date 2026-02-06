package com.chronir.feature.alarmcreation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.organisms.AlarmCreationForm
import com.chronir.designsystem.templates.ModalSheetTemplate

@Composable
fun AlarmCreationScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier
) {
    var title by remember { mutableStateOf("") }
    var timeText by remember { mutableStateOf("08:00 AM") }

    ModalSheetTemplate(
        onDismiss = onDismiss,
        modifier = modifier
    ) {
        AlarmCreationForm(
            title = title,
            onTitleChange = { title = it },
            timeText = timeText,
            onTimeClick = { /* Time picker will be wired with real data later */ },
            onSave = { onDismiss() }
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmCreationScreenPreview() {
    // Bottom sheets require a host; preview is limited
    AlarmCreationForm(
        title = "",
        onTitleChange = {},
        timeText = "08:00 AM",
        onTimeClick = {},
        onSave = {}
    )
}
