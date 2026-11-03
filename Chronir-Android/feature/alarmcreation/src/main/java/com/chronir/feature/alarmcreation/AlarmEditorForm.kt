package com.chronir.feature.alarmcreation

import android.text.format.DateFormat
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.AlertDialogDefaults
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.InputChip
import androidx.compose.material3.InputChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.CategoryPicker
import com.chronir.designsystem.molecules.LabeledTextField
import com.chronir.designsystem.molecules.LockedFieldSection
import com.chronir.designsystem.molecules.TimePickerField
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.util.rememberTimeFormatter
import com.chronir.model.CycleType
import com.chronir.model.FollowUpInterval
import com.chronir.model.PersistenceLevel
import com.chronir.model.PreAlarmOffset
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalTime
import java.time.Month
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.time.format.TextStyle
import java.util.Locale

/**
 * The alarm editor shared by New Alarm and Edit Alarm. Stateless: renders [form] and reports
 * every edit through [onEvent]; the ViewModel reduces it with the tier gates applied.
 * [onLockedFeature] routes taps on Plus-only controls to the paywall.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmEditorForm(
    form: AlarmFormState,
    isPlusTier: Boolean,
    onEvent: (AlarmFormEvent) -> Unit,
    onLockedFeature: () -> Unit,
    modifier: Modifier = Modifier,
    titleError: String? = null,
    header: @Composable ColumnScope.() -> Unit = {},
    footer: @Composable ColumnScope.() -> Unit = {}
) {
    val timeFormatter = rememberTimeFormatter()
    // null = closed; -1 = main time; -2 = new additional time; >= 0 = edit that additional time
    var timePickerTarget by rememberSaveable { mutableStateOf<Int?>(null) }
    var showDatePicker by rememberSaveable { mutableStateOf(false) }
    val dateFormatter = remember { DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM) }

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
    ) {
        header()

        LabeledTextField(
            label = "Alarm Name",
            value = form.title,
            onValueChange = { onEvent(AlarmFormEvent.TitleChanged(it)) },
            placeholder = "Enter alarm name",
            maxLength = AlarmFormState.TITLE_MAX_LENGTH,
            softWarningLength = 32,
            isError = titleError != null,
            supportingText = titleError
        )

        CycleTypeSelector(
            selectedType = form.cycleType,
            onTypeSelected = { onEvent(AlarmFormEvent.CycleTypeChanged(it)) }
        )

        when (form.cycleType) {
            CycleType.ONE_TIME -> TimePickerField(
                label = "Date",
                timeText = form.oneTimeDate.format(dateFormatter),
                onClick = { showDatePicker = true }
            )
            CycleType.WEEKLY -> DayOfWeekPicker(
                selectedDays = form.selectedDays,
                onToggleDay = { onEvent(AlarmFormEvent.DayToggled(it)) }
            )
            CycleType.MONTHLY_DATE -> DayOfMonthPicker(
                dayOfMonth = form.dayOfMonth,
                onDayChanged = { onEvent(AlarmFormEvent.DayOfMonthChanged(it)) }
            )
            CycleType.ANNUAL -> AnnualDatePicker(
                month = form.annualMonth,
                day = form.annualDay,
                onMonthChanged = { onEvent(AlarmFormEvent.AnnualMonthChanged(it)) },
                onDayChanged = { onEvent(AlarmFormEvent.AnnualDayChanged(it)) }
            )
            else -> Unit
        }

        if (form.cycleType != CycleType.ONE_TIME) {
            RepeatIntervalStepper(
                interval = form.repeatInterval,
                cycleType = form.cycleType,
                onIntervalChanged = { onEvent(AlarmFormEvent.RepeatIntervalChanged(it)) }
            )
        }

        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        CategoryPicker(
            selected = form.category,
            onSelect = { onEvent(AlarmFormEvent.CategoryChanged(it)) }
        )

        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        TimePickerField(
            label = "Time",
            timeText = LocalTime.of(form.hour, form.minute).format(timeFormatter),
            onClick = { timePickerTarget = MAIN_TIME }
        )

        AdditionalTimesSection(
            additionalTimes = form.additionalTimes,
            timeFormatter = timeFormatter,
            onAddTime = { timePickerTarget = NEW_ADDITIONAL_TIME },
            onEditTime = { index -> timePickerTarget = index },
            onRemoveTime = { onEvent(AlarmFormEvent.AdditionalTimeRemoved(it)) }
        )

        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        AlarmToggleRow(
            title = "Require Dismissal",
            subtitle = "Alarm repeats after snooze until manually dismissed",
            isEnabled = form.persistenceLevel == PersistenceLevel.FULL,
            onToggle = { onEvent(AlarmFormEvent.PersistenceToggled(it)) }
        )

        if (form.persistenceLevel == PersistenceLevel.FULL) {
            FollowUpIntervalSelector(
                selected = form.followUpInterval,
                onSelect = { onEvent(AlarmFormEvent.FollowUpChanged(it)) }
            )
        }

        PreAlarmOffsetSelector(
            selectedMinutes = form.preAlarmMinutes,
            isPlusTier = isPlusTier,
            onSelect = { onEvent(AlarmFormEvent.PreAlarmChanged(it)) },
            onLockedSelect = onLockedFeature
        )

        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        if (isPlusTier) {
            LabeledTextField(
                label = "Note",
                value = form.note,
                onValueChange = { onEvent(AlarmFormEvent.NoteChanged(it)) },
                placeholder = "Add a note...",
                maxLength = AlarmFormState.NOTE_MAX_LENGTH,
                singleLine = false,
                minLines = 3
            )
        } else {
            LockedFieldSection(
                label = "Note",
                value = form.note,
                placeholder = "Add a note...",
                onClick = onLockedFeature
            )
        }

        footer()

        Spacer(Modifier.height(SpacingTokens.Large))
    }

    timePickerTarget?.let { target ->
        val initial = when {
            target == MAIN_TIME -> LocalTime.of(form.hour, form.minute)
            target >= 0 -> form.additionalTimes.getOrNull(target) ?: LocalTime.NOON
            else -> LocalTime.NOON
        }
        ChronirTimePickerDialog(
            initialTime = initial,
            onConfirm = { time ->
                when {
                    target == MAIN_TIME -> onEvent(AlarmFormEvent.TimeChanged(time.hour, time.minute))
                    target >= 0 -> onEvent(AlarmFormEvent.AdditionalTimeChanged(target, time))
                    else -> onEvent(AlarmFormEvent.AdditionalTimeAdded(time))
                }
                timePickerTarget = null
            },
            onDismiss = { timePickerTarget = null }
        )
    }

    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            // DatePicker works in UTC midnight millis.
            initialSelectedDateMillis = form.oneTimeDate.atStartOfDay(ZoneId.of("UTC")).toInstant().toEpochMilli()
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val date = Instant.ofEpochMilli(millis).atZone(ZoneId.of("UTC")).toLocalDate()
                        onEvent(AlarmFormEvent.OneTimeDateChanged(date))
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

private const val MAIN_TIME = -1
private const val NEW_ADDITIONAL_TIME = -2

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ChronirTimePickerDialog(
    initialTime: LocalTime,
    onConfirm: (LocalTime) -> Unit,
    onDismiss: () -> Unit
) {
    val state = rememberTimePickerState(
        initialHour = initialTime.hour,
        initialMinute = initialTime.minute,
        is24Hour = DateFormat.is24HourFormat(LocalContext.current)
    )
    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = MaterialTheme.shapes.extraLarge,
            tonalElevation = AlertDialogDefaults.TonalElevation
        ) {
            Column(
                modifier = Modifier.padding(SpacingTokens.Large),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                ChronirText(
                    text = "Select time",
                    style = ChronirTextStyle.LabelMedium,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = SpacingTokens.Medium)
                )
                TimePicker(state = state)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) { Text("Cancel") }
                    TextButton(onClick = { onConfirm(LocalTime.of(state.hour, state.minute)) }) { Text("OK") }
                }
            }
        }
    }
}

@Composable
private fun FieldLabel(text: String) {
    ChronirText(
        text = text,
        style = ChronirTextStyle.LabelMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.padding(bottom = SpacingTokens.XXSmall)
    )
}

@Composable
private fun selectedChipColors() = FilterChipDefaults.filterChipColors(
    selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
    selectedLabelColor = MaterialTheme.colorScheme.onPrimaryContainer,
    selectedTrailingIconColor = MaterialTheme.colorScheme.onPrimaryContainer
)

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun CycleTypeSelector(
    selectedType: CycleType,
    onTypeSelected: (CycleType) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        FieldLabel("Repeat")
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            modifier = Modifier.fillMaxWidth()
        ) {
            listOf(CycleType.ONE_TIME, CycleType.WEEKLY, CycleType.MONTHLY_DATE, CycleType.ANNUAL).forEach { type ->
                FilterChip(
                    selected = selectedType == type,
                    onClick = { onTypeSelected(type) },
                    label = { Text(type.displayName, maxLines = 1) },
                    colors = selectedChipColors()
                )
            }
        }
    }
}

/** Calendar-style day values (1 = Sunday … 7 = Saturday) in Monday-first display order. */
private val weekDayOrder = listOf(
    2 to DayOfWeek.MONDAY,
    3 to DayOfWeek.TUESDAY,
    4 to DayOfWeek.WEDNESDAY,
    5 to DayOfWeek.THURSDAY,
    6 to DayOfWeek.FRIDAY,
    7 to DayOfWeek.SATURDAY,
    1 to DayOfWeek.SUNDAY
)

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun DayOfWeekPicker(
    selectedDays: Set<Int>,
    onToggleDay: (Int) -> Unit
) {
    val locale = LocalConfiguration.current.locales[0] ?: Locale.getDefault()
    Column(modifier = Modifier.fillMaxWidth()) {
        FieldLabel("Days")
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XXSmall),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.XXSmall),
            modifier = Modifier.fillMaxWidth()
        ) {
            weekDayOrder.forEach { (dayValue, dayOfWeek) ->
                val isSelected = dayValue in selectedDays
                val fullName = dayOfWeek.getDisplayName(TextStyle.FULL, locale)
                Surface(
                    shape = CircleShape,
                    color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surface,
                    contentColor = if (isSelected) {
                        MaterialTheme.colorScheme.onPrimary
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    },
                    border = BorderStroke(
                        1.dp, // token-exempt: hairline outline of an unselected day
                        if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline
                    ),
                    modifier = Modifier
                        .size(SpacingTokens.TouchMinTarget)
                        .toggleable(
                            value = isSelected,
                            role = Role.Checkbox,
                            onValueChange = { onToggleDay(dayValue) }
                        )
                        .semantics { contentDescription = fullName }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        ChronirText(
                            text = dayOfWeek.getDisplayName(TextStyle.NARROW, locale),
                            style = ChronirTextStyle.BodyMedium,
                            color = if (isSelected) {
                                MaterialTheme.colorScheme.onPrimary
                            } else {
                                MaterialTheme.colorScheme.onSurface
                            }
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun <T> DropdownField(
    label: String,
    selectedText: String,
    options: List<T>,
    optionText: (T) -> String,
    onSelect: (T) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = selectedText,
            onValueChange = {},
            readOnly = true,
            singleLine = true,
            label = { Text(label) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(MenuAnchorType.PrimaryNotEditable)
        )
        ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(optionText(option)) },
                    onClick = {
                        onSelect(option)
                        expanded = false
                    },
                    contentPadding = ExposedDropdownMenuDefaults.ItemContentPadding
                )
            }
        }
    }
}

@Composable
private fun DayOfMonthPicker(
    dayOfMonth: Int,
    onDayChanged: (Int) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        DropdownField(
            label = "Day of month",
            selectedText = "$dayOfMonth",
            options = (1..31).toList(),
            optionText = { "$it" },
            onSelect = onDayChanged
        )
        if (dayOfMonth > 28) {
            ChronirText(
                text = "In months without day $dayOfMonth, the alarm fires on the last day.",
                style = ChronirTextStyle.BodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = SpacingTokens.XXSmall)
            )
        }
    }
}

@Composable
private fun AnnualDatePicker(
    month: Int,
    day: Int,
    onMonthChanged: (Int) -> Unit,
    onDayChanged: (Int) -> Unit
) {
    val locale = LocalConfiguration.current.locales[0] ?: Locale.getDefault()
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)) {
            DropdownField(
                label = "Month",
                selectedText = Month.of(month).getDisplayName(TextStyle.FULL, locale),
                options = (1..12).toList(),
                optionText = { Month.of(it).getDisplayName(TextStyle.FULL, locale) },
                onSelect = onMonthChanged,
                modifier = Modifier.weight(2f)
            )
            DropdownField(
                label = "Day",
                selectedText = "$day",
                options = (1..AlarmFormState.maxDayOfMonth(month)).toList(),
                optionText = { "$it" },
                onSelect = onDayChanged,
                modifier = Modifier.weight(1f)
            )
        }
        if (month == 2 && day == 29) {
            ChronirText(
                text = "In non-leap years, the alarm fires on February 28.",
                style = ChronirTextStyle.BodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = SpacingTokens.XXSmall)
            )
        }
    }
}

@Composable
private fun RepeatIntervalStepper(
    interval: Int,
    cycleType: CycleType,
    onIntervalChanged: (Int) -> Unit
) {
    val unitLabel = when (cycleType) {
        CycleType.WEEKLY -> if (interval == 1) "week" else "weeks"
        CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> if (interval == 1) "month" else "months"
        CycleType.ANNUAL -> if (interval == 1) "year" else "years"
        else -> ""
    }
    Column(modifier = Modifier.fillMaxWidth()) {
        FieldLabel("Repeat every")
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(
                onClick = { onIntervalChanged(interval - 1) },
                enabled = interval > 1
            ) {
                Icon(Icons.Filled.Remove, contentDescription = "Decrease interval")
            }
            ChronirText(
                text = "$interval $unitLabel",
                style = ChronirTextStyle.TitleMedium,
                modifier = Modifier
                    .padding(horizontal = SpacingTokens.XSmall)
                    .semantics {
                        liveRegion = LiveRegionMode.Polite
                        stateDescription = "Every $interval $unitLabel"
                    }
            )
            IconButton(
                onClick = { onIntervalChanged(interval + 1) },
                enabled = interval < AlarmFormState.MAX_REPEAT_INTERVAL
            ) {
                Icon(Icons.Filled.Add, contentDescription = "Increase interval")
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun PreAlarmOffsetSelector(
    selectedMinutes: Int,
    isPlusTier: Boolean,
    onSelect: (Int) -> Unit,
    onLockedSelect: () -> Unit
) {
    // An alarm saved with a non-standard offset keeps showing (and keeping) it.
    val offsets = AlarmFormState.STANDARD_PRE_ALARM_OFFSETS.let { standard ->
        val current = PreAlarmOffset.entries.firstOrNull { it.minutes == selectedMinutes }
        if (current != null && current !in standard) (standard + current).sortedBy { it.minutes } else standard
    }
    Column(modifier = Modifier.fillMaxWidth()) {
        FieldLabel("Pre-alarm warning")
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
        ) {
            offsets.forEach { offset ->
                val isSelected = selectedMinutes == offset.minutes
                val isLocked = !isSelected && AlarmFormState.isPreAlarmLocked(offset.minutes, isPlusTier)
                FilterChip(
                    selected = isSelected,
                    onClick = { if (isLocked) onLockedSelect() else onSelect(offset.minutes) },
                    label = { Text(offset.displayName) },
                    trailingIcon = if (isLocked) {
                        {
                            Icon(
                                Icons.Filled.Lock,
                                contentDescription = "Requires Plus",
                                modifier = Modifier.size(FilterChipDefaults.IconSize)
                            )
                        }
                    } else {
                        null
                    },
                    colors = selectedChipColors()
                )
            }
        }
        if (!isPlusTier) {
            ChronirText(
                text = "Free includes warnings up to 30 minutes before. Longer warnings need Plus.",
                style = ChronirTextStyle.BodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = SpacingTokens.XXSmall)
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun FollowUpIntervalSelector(
    selected: FollowUpInterval,
    onSelect: (FollowUpInterval) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        FieldLabel("Follow-up interval")
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
        ) {
            FollowUpInterval.entries.forEach { interval ->
                FilterChip(
                    selected = selected == interval,
                    onClick = { onSelect(interval) },
                    label = { Text(interval.displayName) },
                    colors = selectedChipColors()
                )
            }
        }
        ChronirText(
            text = "How often to ask \"Did you complete it?\" after stopping.",
            style = ChronirTextStyle.BodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = SpacingTokens.XXSmall)
        )
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun AdditionalTimesSection(
    additionalTimes: List<LocalTime>,
    timeFormatter: DateTimeFormatter,
    onAddTime: () -> Unit,
    onEditTime: (Int) -> Unit,
    onRemoveTime: (Int) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        if (additionalTimes.isNotEmpty()) {
            FieldLabel("Additional times")
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
                verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
            ) {
                additionalTimes.forEachIndexed { index, time ->
                    val label = time.format(timeFormatter)
                    InputChip(
                        selected = false,
                        onClick = { onEditTime(index) },
                        label = { Text(label) },
                        trailingIcon = {
                            IconButton(
                                onClick = { onRemoveTime(index) },
                                modifier = Modifier.size(InputChipDefaults.AvatarSize)
                            ) {
                                Icon(
                                    Icons.Filled.Close,
                                    contentDescription = "Remove $label",
                                    modifier = Modifier.size(InputChipDefaults.IconSize)
                                )
                            }
                        }
                    )
                }
            }
        }
        TextButton(onClick = onAddTime) {
            Icon(Icons.Filled.Add, contentDescription = null, modifier = Modifier.size(FilterChipDefaults.IconSize))
            Spacer(Modifier.width(SpacingTokens.XSmall))
            Text("Add another time")
        }
    }
}

@ChronirPreview
@Composable
private fun AlarmEditorFormFreePreview() {
    ChronirTheme(dynamicColor = false) {
        Surface {
            AlarmEditorForm(
                form = AlarmFormState(
                    title = "Pay Rent",
                    cycleType = CycleType.MONTHLY_DATE,
                    dayOfMonth = 31,
                    additionalTimes = listOf(LocalTime.of(18, 0))
                ),
                isPlusTier = false,
                onEvent = {},
                onLockedFeature = {},
                modifier = Modifier.padding(SpacingTokens.Default)
            )
        }
    }
}

@ChronirPreview
@Composable
private fun AlarmEditorFormErrorPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface {
            AlarmEditorForm(
                form = AlarmFormState(cycleType = CycleType.ANNUAL, annualMonth = 2, annualDay = 29),
                isPlusTier = true,
                onEvent = {},
                onLockedFeature = {},
                titleError = "Enter a name for this alarm.",
                modifier = Modifier.padding(SpacingTokens.Default)
            )
        }
    }
}
