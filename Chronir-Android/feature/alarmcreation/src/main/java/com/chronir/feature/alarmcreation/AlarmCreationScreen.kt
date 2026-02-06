package com.chronir.feature.alarmcreation

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.organisms.AlarmCreationForm
import com.chronir.designsystem.templates.ModalSheetTemplate
import com.chronir.model.CycleType

@Composable
fun AlarmCreationScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmCreationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState.saveSuccess) {
        if (uiState.saveSuccess) {
            onDismiss()
        }
    }

    ModalSheetTemplate(
        onDismiss = onDismiss,
        modifier = modifier
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
        ) {
            AlarmCreationForm(
                title = uiState.title,
                onTitleChange = viewModel::updateTitle,
                timeText = formatTime(uiState.hour, uiState.minute),
                onTimeClick = { /* Time picker dialog will be added later */ },
                onSave = viewModel::saveAlarm
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Cycle type selector
            CycleTypeSelector(
                selectedType = uiState.cycleType,
                onTypeSelected = viewModel::updateCycleType
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Schedule configuration based on cycle type
            when (uiState.cycleType) {
                CycleType.WEEKLY -> DayOfWeekPicker(
                    selectedDays = uiState.selectedDays,
                    onToggleDay = viewModel::toggleDay
                )
                CycleType.MONTHLY_DATE -> DayOfMonthPicker(
                    dayOfMonth = uiState.dayOfMonth,
                    onDayChanged = viewModel::updateDayOfMonth
                )
                else -> { /* Other cycle types will be wired later */ }
            }

            // Error message
            uiState.errorMessage?.let { error ->
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = error,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
private fun CycleTypeSelector(
    selectedType: CycleType,
    onTypeSelected: (CycleType) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "Repeat",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            listOf(CycleType.WEEKLY, CycleType.MONTHLY_DATE, CycleType.ANNUAL).forEach { type ->
                FilterChip(
                    selected = selectedType == type,
                    onClick = { onTypeSelected(type) },
                    label = { Text(type.displayName) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                        selectedLabelColor = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                )
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun DayOfWeekPicker(
    selectedDays: Set<Int>,
    onToggleDay: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val dayLabels = listOf(
        2 to "M", 3 to "T", 4 to "W", 5 to "T", 6 to "F", 7 to "S", 1 to "S"
    )

    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "Days",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            dayLabels.forEach { (dayValue, label) ->
                val isSelected = selectedDays.contains(dayValue)
                Surface(
                    onClick = { onToggleDay(dayValue) },
                    shape = CircleShape,
                    color = if (isSelected) {
                        MaterialTheme.colorScheme.primary
                    } else {
                        MaterialTheme.colorScheme.surface
                    },
                    border = BorderStroke(
                        1.dp,
                        if (isSelected) {
                            MaterialTheme.colorScheme.primary
                        } else {
                            MaterialTheme.colorScheme.outline
                        }
                    ),
                    modifier = Modifier.size(40.dp)
                ) {
                    Text(
                        text = label,
                        color = if (isSelected) {
                            MaterialTheme.colorScheme.onPrimary
                        } else {
                            MaterialTheme.colorScheme.onSurface
                        },
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(8.dp),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
private fun DayOfMonthPicker(
    dayOfMonth: Int,
    onDayChanged: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "Day of Month",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Surface(
                onClick = { onDayChanged((dayOfMonth - 1).coerceAtLeast(1)) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                Text(
                    text = "-",
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(6.dp)
                )
            }
            Text(
                text = "$dayOfMonth",
                style = MaterialTheme.typography.headlineSmall
            )
            Surface(
                onClick = { onDayChanged((dayOfMonth + 1).coerceAtMost(31)) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                Text(
                    text = "+",
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(6.dp)
                )
            }
        }
    }
}

private fun formatTime(hour: Int, minute: Int): String {
    val period = if (hour < 12) "AM" else "PM"
    val displayHour = when {
        hour == 0 -> 12
        hour > 12 -> hour - 12
        else -> hour
    }
    return "%d:%02d %s".format(displayHour, minute, period)
}

@Preview(showBackground = true)
@Composable
private fun AlarmCreationScreenPreview() {
    AlarmCreationForm(
        title = "",
        onTitleChange = {},
        timeText = "08:00 AM",
        onTimeClick = {},
        onSave = {}
    )
}
