package com.chronir.feature.alarmcreation

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.CategoryPicker
import com.chronir.designsystem.molecules.LabeledTextField
import com.chronir.designsystem.molecules.TimePickerField
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.CycleType
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmCreationScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmCreationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showTimePicker by remember { mutableStateOf(false) }
    var showDatePicker by remember { mutableStateOf(false) }

    LaunchedEffect(uiState.saveSuccess) {
        if (uiState.saveSuccess) onDismiss()
    }

    Scaffold(
        modifier = modifier,
        topBar = {
            TopAppBar(
                title = { Text("New Alarm") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Filled.Close, contentDescription = "Cancel")
                    }
                },
                actions = {
                    TextButton(
                        onClick = viewModel::saveAlarm,
                        enabled = !uiState.isSaving
                    ) {
                        Text("Save")
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Default),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
        ) {
            // Alarm Name
            LabeledTextField(
                label = "Alarm Name",
                value = uiState.title,
                onValueChange = viewModel::updateTitle,
                placeholder = "Enter alarm name",
                maxLength = 60
            )

            // Repeat Chips
            CycleTypeSelector(
                selectedType = uiState.cycleType,
                onTypeSelected = viewModel::updateCycleType
            )

            // Conditional schedule pickers
            when (uiState.cycleType) {
                CycleType.ONE_TIME -> {
                    OneTimeDatePicker(
                        date = uiState.oneTimeDate,
                        onClick = { showDatePicker = true }
                    )
                }
                CycleType.WEEKLY -> DayOfWeekPicker(
                    selectedDays = uiState.selectedDays,
                    onToggleDay = viewModel::toggleDay
                )
                CycleType.MONTHLY_DATE -> DayOfMonthPicker(
                    dayOfMonth = uiState.dayOfMonth,
                    onDayChanged = viewModel::updateDayOfMonth
                )
                CycleType.ANNUAL -> AnnualPicker(
                    month = uiState.annualMonth,
                    day = uiState.annualDay,
                    onMonthChanged = viewModel::updateAnnualMonth,
                    onDayChanged = viewModel::updateAnnualDay
                )
                else -> {}
            }

            // Repeat interval (hidden for One-Time)
            if (uiState.cycleType != CycleType.ONE_TIME) {
                RepeatIntervalStepper(
                    interval = uiState.repeatInterval,
                    cycleType = uiState.cycleType,
                    onIntervalChanged = viewModel::updateRepeatInterval
                )
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outline)

            // Category
            CategoryPicker(
                selected = uiState.category,
                onSelect = viewModel::updateCategory
            )

            HorizontalDivider(color = MaterialTheme.colorScheme.outline)

            // Time
            TimePickerField(
                label = "Time",
                timeText = formatTime(uiState.hour, uiState.minute),
                onClick = { showTimePicker = true }
            )

            HorizontalDivider(color = MaterialTheme.colorScheme.outline)

            // Persistent toggle
            AlarmToggleRow(
                title = "Persistent",
                subtitle = "Requires dismissal to stop",
                isEnabled = uiState.persistenceLevel == com.chronir.model.PersistenceLevel.FULL,
                onToggle = viewModel::togglePersistence
            )

            // Pre-alarm warning toggle
            AlarmToggleRow(
                title = "24h Pre-Alarm Warning",
                subtitle = "Get notified 24 hours before",
                isEnabled = uiState.preAlarmEnabled,
                onToggle = viewModel::updatePreAlarmEnabled
            )

            HorizontalDivider(color = MaterialTheme.colorScheme.outline)

            // Note
            LabeledTextField(
                label = "Note",
                value = uiState.note,
                onValueChange = viewModel::updateNote,
                placeholder = "Add a note...",
                maxLength = 500,
                singleLine = false,
                minLines = 3
            )

            // Error message
            uiState.errorMessage?.let { error ->
                ChronirText(
                    text = error,
                    color = ColorTokens.Error,
                    style = ChronirTextStyle.BodySmall,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(Modifier.height(SpacingTokens.Large))
        }
    }

    // Time picker dialog
    if (showTimePicker) {
        TimePickerDialog(
            initialHour = uiState.hour,
            initialMinute = uiState.minute,
            onConfirm = { hour, minute ->
                viewModel.updateTime(hour, minute)
                showTimePicker = false
            },
            onDismiss = { showTimePicker = false }
        )
    }

    // Date picker dialog (for One-Time)
    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = uiState.oneTimeDate
                .atStartOfDay(ZoneId.systemDefault())
                .toInstant()
                .toEpochMilli()
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val date = Instant.ofEpochMilli(millis)
                            .atZone(ZoneId.systemDefault())
                            .toLocalDate()
                        viewModel.updateOneTimeDate(date)
                    }
                    showDatePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Cancel") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun TimePickerDialog(
    initialHour: Int,
    initialMinute: Int,
    onConfirm: (Int, Int) -> Unit,
    onDismiss: () -> Unit
) {
    val timePickerState = rememberTimePickerState(
        initialHour = initialHour,
        initialMinute = initialMinute
    )

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = MaterialTheme.shapes.extraLarge,
            tonalElevation = 6.dp
        ) {
            Column(
                modifier = Modifier.padding(SpacingTokens.Large),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                ChronirText(
                    text = "Select Time",
                    style = ChronirTextStyle.LabelMedium,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 20.dp)
                )
                TimePicker(state = timePickerState)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) { Text("Cancel") }
                    TextButton(
                        onClick = { onConfirm(timePickerState.hour, timePickerState.minute) }
                    ) { Text("OK") }
                }
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
        ChronirText(
            text = "Repeat",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        Row(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            modifier = Modifier.fillMaxWidth()
        ) {
            listOf(
                CycleType.ONE_TIME,
                CycleType.WEEKLY,
                CycleType.MONTHLY_DATE,
                CycleType.ANNUAL
            ).forEach { type ->
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

@Composable
private fun OneTimeDatePicker(
    date: LocalDate,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val formatter = remember { DateTimeFormatter.ofPattern("EEE, MMM d, yyyy") }
    Column(modifier = modifier.fillMaxWidth()) {
        ChronirText(
            text = "Date",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        FilterChip(
            selected = true,
            onClick = onClick,
            label = { Text(date.format(formatter)) }
        )
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
        ChronirText(
            text = "Days",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            modifier = Modifier.fillMaxWidth()
        ) {
            dayLabels.forEach { (dayValue, label) ->
                val isSelected = selectedDays.contains(dayValue)
                Surface(
                    onClick = { onToggleDay(dayValue) },
                    shape = CircleShape,
                    color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surface,
                    border = BorderStroke(
                        1.dp,
                        if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline
                    ),
                    modifier = Modifier.size(40.dp)
                ) {
                    ChronirText(
                        text = label,
                        color = if (isSelected) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurface,
                        style = ChronirTextStyle.BodyMedium,
                        modifier = Modifier
                            .fillMaxSize()
                            .wrapContentSize(Alignment.Center),
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
        ChronirText(
            text = "Day of Month",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
        ) {
            Surface(
                onClick = { onDayChanged((dayOfMonth - 1).coerceAtLeast(1)) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                ChronirText(
                    text = "-",
                    textAlign = TextAlign.Center,
                    style = ChronirTextStyle.TitleMedium,
                    modifier = Modifier.padding(6.dp)
                )
            }
            ChronirText(
                text = "$dayOfMonth",
                style = ChronirTextStyle.HeadlineSmall
            )
            Surface(
                onClick = { onDayChanged((dayOfMonth + 1).coerceAtMost(31)) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                ChronirText(
                    text = "+",
                    textAlign = TextAlign.Center,
                    style = ChronirTextStyle.TitleMedium,
                    modifier = Modifier.padding(6.dp)
                )
            }
        }
    }
}

@Composable
private fun AnnualPicker(
    month: Int,
    day: Int,
    onMonthChanged: (Int) -> Unit,
    onDayChanged: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val months = listOf(
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    )

    Column(modifier = modifier.fillMaxWidth()) {
        ChronirText(
            text = "Date",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
        ) {
            // Month stepper
            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    onClick = { onMonthChanged((month - 1).coerceAtLeast(1)) },
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    modifier = Modifier.size(32.dp)
                ) {
                    ChronirText(
                        text = "-",
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(SpacingTokens.XXSmall)
                    )
                }
                ChronirText(
                    text = months[month - 1],
                    style = ChronirTextStyle.TitleMedium,
                    modifier = Modifier.padding(horizontal = SpacingTokens.XSmall)
                )
                Surface(
                    onClick = { onMonthChanged((month + 1).coerceAtMost(12)) },
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    modifier = Modifier.size(32.dp)
                ) {
                    ChronirText(
                        text = "+",
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(SpacingTokens.XXSmall)
                    )
                }
            }

            // Day stepper
            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    onClick = { onDayChanged((day - 1).coerceAtLeast(1)) },
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    modifier = Modifier.size(32.dp)
                ) {
                    ChronirText(
                        text = "-",
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(SpacingTokens.XXSmall)
                    )
                }
                ChronirText(
                    text = "$day",
                    style = ChronirTextStyle.TitleMedium,
                    modifier = Modifier.padding(horizontal = SpacingTokens.XSmall)
                )
                Surface(
                    onClick = { onDayChanged((day + 1).coerceAtMost(31)) },
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    modifier = Modifier.size(32.dp)
                ) {
                    ChronirText(
                        text = "+",
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(SpacingTokens.XXSmall)
                    )
                }
            }
        }
    }
}

@Composable
private fun RepeatIntervalStepper(
    interval: Int,
    cycleType: CycleType,
    onIntervalChanged: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val unitLabel = when (cycleType) {
        CycleType.WEEKLY -> if (interval == 1) "week" else "weeks"
        CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> if (interval == 1) "month" else "months"
        CycleType.ANNUAL -> if (interval == 1) "year" else "years"
        else -> ""
    }

    Column(modifier = modifier.fillMaxWidth()) {
        ChronirText(
            text = "Repeat Every",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
        ) {
            Surface(
                onClick = { onIntervalChanged(interval - 1) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                ChronirText(
                    text = "-",
                    textAlign = TextAlign.Center,
                    style = ChronirTextStyle.TitleMedium,
                    modifier = Modifier.padding(6.dp)
                )
            }
            ChronirText(
                text = "$interval $unitLabel",
                style = ChronirTextStyle.TitleMedium
            )
            Surface(
                onClick = { onIntervalChanged(interval + 1) },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(36.dp)
            ) {
                ChronirText(
                    text = "+",
                    textAlign = TextAlign.Center,
                    style = ChronirTextStyle.TitleMedium,
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
    ChronirButton(
        text = "Save Alarm",
        onClick = {},
        modifier = Modifier
            .fillMaxWidth()
            .padding(SpacingTokens.Medium)
    )
}
