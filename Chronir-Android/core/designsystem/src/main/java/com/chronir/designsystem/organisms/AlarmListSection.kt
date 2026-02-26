package com.chronir.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime

@Composable
fun AlarmListSection(
    sectionTitle: String,
    alarms: List<Alarm>,
    enabledStates: Map<String, Boolean>,
    onToggle: (Alarm, Boolean) -> Unit,
    onClick: (Alarm) -> Unit,
    modifier: Modifier = Modifier,
    onDelete: ((Alarm) -> Unit)? = null
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.Small),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
    ) {
        if (sectionTitle.isNotEmpty()) {
            Row(
                modifier = Modifier.padding(horizontal = SpacingTokens.Default),
                verticalAlignment = Alignment.CenterVertically
            ) {
                ChronirText(
                    text = sectionTitle.uppercase(),
                    style = ChronirTextStyle.LabelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(Modifier.width(SpacingTokens.XSmall))
                ChronirBadge(
                    label = "${alarms.size}",
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            }
        }

        alarms.forEach { alarm ->
            val isEnabled = enabledStates[alarm.id] ?: alarm.isEnabled
            val visualState = when {
                !isEnabled -> AlarmVisualState.Inactive
                alarm.isPendingConfirmation -> AlarmVisualState.Pending
                alarm.snoozeCount > 0 -> AlarmVisualState.Snoozed
                alarm.nextFireDate.isBefore(Instant.now()) -> AlarmVisualState.Overdue
                else -> AlarmVisualState.Active
            }

            AlarmCard(
                alarm = alarm,
                visualState = visualState,
                isEnabled = isEnabled,
                onToggle = { newValue -> onToggle(alarm, newValue) },
                onClick = { onClick(alarm) },
                onDelete = onDelete?.let { delete -> { delete(alarm) } },
                modifier = Modifier.padding(horizontal = SpacingTokens.Default)
            )
        }
    }
}

@ChronirPreview
@Composable
private fun AlarmListSectionPreview() {
    val alarms = listOf(
        Alarm(
            title = "Morning Workout",
            cycleType = CycleType.WEEKLY,
            timeOfDay = LocalTime.of(7, 0),
            schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
            nextFireDate = Instant.now().plusSeconds(3600),
            persistenceLevel = PersistenceLevel.FULL
        ),
        Alarm(
            title = "Pay Rent",
            cycleType = CycleType.MONTHLY_DATE,
            timeOfDay = LocalTime.of(9, 0),
            schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
            nextFireDate = Instant.now().minusSeconds(3600)
        ),
        Alarm(
            title = "Annual Checkup",
            cycleType = CycleType.ANNUAL,
            timeOfDay = LocalTime.of(10, 0),
            schedule = Schedule.Annual(month = 3, dayOfMonth = 15, interval = 1),
            nextFireDate = Instant.now().plusSeconds(86400)
        )
    )

    ChronirTheme(dynamicColor = false) {
        AlarmListSection(
            sectionTitle = "Upcoming",
            alarms = alarms,
            enabledStates = emptyMap(),
            onToggle = { _, _ -> },
            onClick = {},
            onDelete = {}
        )
    }
}
