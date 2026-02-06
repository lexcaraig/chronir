package com.chronir.designsystem.organisms

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.atoms.ChronirToggle
import com.chronir.designsystem.molecules.AlarmTimeDisplay
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import java.time.Instant
import java.time.LocalTime
import java.time.format.DateTimeFormatter

enum class AlarmVisualState {
    Active,
    Inactive,
    Snoozed,
    Overdue;

    val accentColor: Color?
        get() = when (this) {
            Active -> null
            Inactive -> null
            Snoozed -> ColorTokens.Warning
            Overdue -> ColorTokens.Error
        }

    val statusBadgeLabel: String?
        get() = when (this) {
            Active -> null
            Inactive -> null
            Snoozed -> "Snoozed"
            Overdue -> "Missed"
        }

    val statusBadgeColor: Color
        get() = when (this) {
            Snoozed -> ColorTokens.Warning
            Overdue -> ColorTokens.Error
            else -> Color.Transparent
        }
}

private val cycleTypeBadgeColor: (CycleType) -> Color = { cycleType ->
    when (cycleType) {
        CycleType.WEEKLY -> ColorTokens.BadgeWeekly
        CycleType.MONTHLY -> ColorTokens.BadgeMonthly
        CycleType.ANNUAL -> ColorTokens.BadgeAnnual
        CycleType.CUSTOM -> ColorTokens.BadgeCustom
        else -> ColorTokens.AccentPrimary
    }
}

private val cycleTypeLabel: (CycleType) -> String = { cycleType ->
    when (cycleType) {
        CycleType.WEEKLY -> "Weekly"
        CycleType.BIWEEKLY -> "Biweekly"
        CycleType.MONTHLY -> "Monthly"
        CycleType.QUARTERLY -> "Quarterly"
        CycleType.BIANNUAL -> "Biannual"
        CycleType.ANNUAL -> "Annual"
        CycleType.CUSTOM -> "Custom"
    }
}

@Composable
fun AlarmCard(
    alarm: Alarm,
    visualState: AlarmVisualState,
    isEnabled: Boolean,
    onToggle: (Boolean) -> Unit,
    onClick: () -> Unit,
    onDelete: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val cardContent: @Composable () -> Unit = {
        Card(
            onClick = onClick,
            modifier = modifier
                .fillMaxWidth()
                .alpha(if (visualState == AlarmVisualState.Inactive) 0.5f else 1f),
            shape = RoundedCornerShape(RadiusTokens.Md),
            colors = CardDefaults.cardColors(containerColor = ColorTokens.SurfaceCard),
            border = visualState.accentColor?.let {
                androidx.compose.foundation.BorderStroke(2.dp, it)
            }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Large)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        ChronirText(
                            text = alarm.title,
                            style = ChronirTextStyle.TitleMedium,
                            color = if (visualState == AlarmVisualState.Inactive) ColorTokens.TextDisabled else ColorTokens.TextPrimary
                        )
                        Spacer(Modifier.height(SpacingTokens.XXSmall))
                        Row {
                            ChronirBadge(
                                label = cycleTypeLabel(alarm.cycleType),
                                containerColor = cycleTypeBadgeColor(alarm.cycleType)
                            )
                            visualState.statusBadgeLabel?.let { label ->
                                Spacer(Modifier.width(SpacingTokens.XSmall))
                                ChronirBadge(
                                    label = label,
                                    containerColor = visualState.statusBadgeColor
                                )
                            }
                        }
                    }
                    ChronirToggle(
                        checked = isEnabled,
                        onCheckedChange = onToggle
                    )
                }

                Spacer(Modifier.height(SpacingTokens.Small))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val timeFormatter = remember { DateTimeFormatter.ofPattern("h:mm a") }
                    if (visualState != AlarmVisualState.Inactive) {
                        AlarmTimeDisplay(
                            timeText = alarm.scheduledTime.format(timeFormatter),
                            countdownText = if (visualState == AlarmVisualState.Active) "Alarm in 6h 32m" else null
                        )
                    } else {
                        ChronirText(
                            text = alarm.scheduledTime.format(timeFormatter),
                            style = ChronirTextStyle.HeadlineTime,
                            color = ColorTokens.TextDisabled
                        )
                    }
                    Spacer(Modifier.weight(1f))
                    if (alarm.isPersistent) {
                        ChronirBadge(
                            label = "Persistent",
                            containerColor = ColorTokens.Warning
                        )
                    }
                }
            }
        }
    }

    if (onDelete != null) {
        val dismissState = rememberSwipeToDismissBoxState(
            confirmValueChange = { value ->
                if (value == SwipeToDismissBoxValue.EndToStart) {
                    onDelete()
                    true
                } else {
                    false
                }
            }
        )
        SwipeToDismissBox(
            state = dismissState,
            backgroundContent = {},
            enableDismissFromStartToEnd = false
        ) {
            cardContent()
        }
    } else {
        cardContent()
    }
}

// MARK: - Previews

private val sampleAlarm = Alarm(
    title = "Morning Workout",
    cycleType = CycleType.WEEKLY,
    scheduledTime = LocalTime.of(7, 0),
    nextFireDate = Instant.now(),
    isPersistent = true
)

private val sampleAlarmMonthly = Alarm(
    title = "Pay Rent",
    cycleType = CycleType.MONTHLY,
    scheduledTime = LocalTime.of(9, 0),
    nextFireDate = Instant.now()
)

@ChronirPreview
@Composable
private fun AlarmCardActivePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarm,
            visualState = AlarmVisualState.Active,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardInactivePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarmMonthly,
            visualState = AlarmVisualState.Inactive,
            isEnabled = false,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardSnoozedPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarm,
            visualState = AlarmVisualState.Snoozed,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardOverduePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarmMonthly,
            visualState = AlarmVisualState.Overdue,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
