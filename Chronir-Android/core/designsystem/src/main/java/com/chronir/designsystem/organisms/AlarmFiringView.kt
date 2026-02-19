package com.chronir.designsystem.organisms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.SnoozeInterval
import com.chronir.designsystem.molecules.SnoozeOptionBar
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime
import java.time.format.DateTimeFormatter

@Composable
fun AlarmFiringView(
    alarm: Alarm,
    onDismiss: () -> Unit,
    onSnooze: (SnoozeInterval) -> Unit,
    modifier: Modifier = Modifier,
    snoozeCount: Int = 0
) {
    val timeFormatter = DateTimeFormatter.ofPattern("h:mm a")

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(ColorTokens.FiringBackground)
            .padding(SpacingTokens.XXLarge),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(Modifier.weight(1f))

        ChronirText(
            text = alarm.title,
            style = ChronirTextStyle.HeadlineLarge,
            color = ColorTokens.FiringForeground
        )

        Spacer(Modifier.height(SpacingTokens.Small))

        ChronirText(
            text = alarm.timeOfDay.format(timeFormatter),
            style = ChronirTextStyle.DisplayAlarm,
            color = ColorTokens.FiringForeground
        )

        Spacer(Modifier.height(SpacingTokens.Medium))

        ChronirBadge(
            label = cycleTypeLabel(alarm.cycleType),
            containerColor = cycleTypeBadgeColor(alarm.cycleType)
        )

        if (alarm.note.isNotEmpty()) {
            Spacer(Modifier.height(SpacingTokens.Medium))
            ChronirText(
                text = alarm.note,
                style = ChronirTextStyle.BodySecondary,
                color = ColorTokens.FiringForeground.copy(alpha = 0.7f)
            )
        }

        if (snoozeCount > 0) {
            Spacer(Modifier.height(SpacingTokens.Small))
            ChronirText(
                text = "Snoozed $snoozeCount time${if (snoozeCount == 1) "" else "s"}",
                style = ChronirTextStyle.BodySecondary,
                color = ColorTokens.Warning
            )
        }

        Spacer(Modifier.weight(1f))

        SnoozeOptionBar(onSnooze = onSnooze)

        Spacer(Modifier.height(SpacingTokens.Medium))

        ChronirButton(
            text = "Dismiss",
            onClick = onDismiss,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = SpacingTokens.XXLarge)
        )

        Spacer(Modifier.weight(0.5f))
    }
}

// Helper functions to avoid circular dependency with AlarmCard
private val cycleTypeBadgeColor: (CycleType) -> androidx.compose.ui.graphics.Color = { cycleType ->
    when (cycleType) {
        CycleType.ONE_TIME -> ColorTokens.BadgeOneTime
        CycleType.WEEKLY -> ColorTokens.BadgeWeekly
        CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> ColorTokens.BadgeMonthly
        CycleType.ANNUAL -> ColorTokens.BadgeAnnual
        CycleType.CUSTOM_DAYS -> ColorTokens.BadgeCustom
    }
}

private val cycleTypeLabel: (CycleType) -> String = { cycleType ->
    when (cycleType) {
        CycleType.ONE_TIME -> "One-Time"
        CycleType.WEEKLY -> "Weekly"
        CycleType.MONTHLY_DATE -> "Monthly"
        CycleType.MONTHLY_RELATIVE -> "Monthly"
        CycleType.ANNUAL -> "Annual"
        CycleType.CUSTOM_DAYS -> "Custom"
    }
}

private val sampleAlarm = Alarm(
    title = "Morning Workout",
    cycleType = CycleType.WEEKLY,
    timeOfDay = LocalTime.of(7, 0),
    schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
    nextFireDate = Instant.now(),
    persistenceLevel = PersistenceLevel.FULL
)

@ChronirPreview
@Composable
private fun AlarmFiringViewPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = sampleAlarm,
            onDismiss = {},
            onSnooze = {}
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmFiringViewWithNotePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = Alarm(
                title = "Pay Rent",
                cycleType = CycleType.MONTHLY_DATE,
                timeOfDay = LocalTime.of(9, 0),
                schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
                nextFireDate = Instant.now(),
                note = "Transfer to landlord account"
            ),
            onDismiss = {},
            onSnooze = {}
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmFiringViewSnoozedPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = sampleAlarm,
            onDismiss = {},
            onSnooze = {},
            snoozeCount = 2
        )
    }
}
