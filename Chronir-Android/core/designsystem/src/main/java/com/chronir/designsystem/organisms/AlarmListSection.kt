package com.chronir.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
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
    val now = remember(alarms) { Instant.now() }
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.Small),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
    ) {
        if (sectionTitle.isNotEmpty()) {
            AlarmSectionHeader(title = sectionTitle, count = alarms.size)
        }
        alarms.forEach { alarm ->
            AlarmListItem(alarm, enabledStates, now, onToggle, onClick, onDelete)
        }
    }
}

/**
 * Lazy variant of [AlarmListSection] for a `LazyColumn` (e.g. `SingleColumnTemplate(lazyContent = …)`):
 * the header and every card are separate keyed items, so off-screen cards are not composed and items
 * can animate. Keys are `"$keyPrefix-header"` and the alarm id.
 */
fun LazyListScope.alarmListSection(
    sectionTitle: String,
    alarms: List<Alarm>,
    enabledStates: Map<String, Boolean>,
    onToggle: (Alarm, Boolean) -> Unit,
    onClick: (Alarm) -> Unit,
    onDelete: ((Alarm) -> Unit)? = null,
    keyPrefix: String = sectionTitle
) {
    if (sectionTitle.isNotEmpty()) {
        item(key = "$keyPrefix-header") {
            AlarmSectionHeader(
                title = sectionTitle,
                count = alarms.size,
                modifier = Modifier.padding(top = SpacingTokens.Small)
            )
        }
    }
    items(alarms, key = { it.id }) { alarm ->
        val now = remember(alarm) { Instant.now() }
        AlarmListItem(
            alarm = alarm,
            enabledStates = enabledStates,
            now = now,
            onToggle = onToggle,
            onClick = onClick,
            onDelete = onDelete,
            modifier = Modifier.padding(vertical = SpacingTokens.XXSmall)
        )
    }
}

/** Material section header: sentence case, titleSmall in primary, announced as a heading. */
@Composable
private fun AlarmSectionHeader(title: String, count: Int, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .padding(horizontal = SpacingTokens.Default)
            .semantics(mergeDescendants = true) { heading() },
        verticalAlignment = Alignment.CenterVertically
    ) {
        ChronirText(
            text = title,
            style = ChronirTextStyle.TitleSmall,
            color = MaterialTheme.colorScheme.primary
        )
        Spacer(Modifier.width(SpacingTokens.XSmall))
        ChronirBadge(
            label = "$count",
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun AlarmListItem(
    alarm: Alarm,
    enabledStates: Map<String, Boolean>,
    now: Instant,
    onToggle: (Alarm, Boolean) -> Unit,
    onClick: (Alarm) -> Unit,
    onDelete: ((Alarm) -> Unit)?,
    modifier: Modifier = Modifier
) {
    val isEnabled = enabledStates[alarm.id] ?: alarm.isEnabled
    val visualState = when {
        !isEnabled -> AlarmVisualState.Inactive
        alarm.isPendingConfirmation -> AlarmVisualState.Pending
        alarm.snoozeCount > 0 -> AlarmVisualState.Snoozed
        alarm.nextFireDate.isBefore(now) -> AlarmVisualState.Overdue
        else -> AlarmVisualState.Active
    }
    AlarmCard(
        alarm = alarm,
        visualState = visualState,
        isEnabled = isEnabled,
        onToggle = { newValue -> onToggle(alarm, newValue) },
        onClick = { onClick(alarm) },
        onDelete = onDelete?.let { delete -> { delete(alarm) } },
        modifier = modifier.padding(horizontal = SpacingTokens.Default)
    )
}

private val previewAlarms = listOf(
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

@ChronirPreview
@Composable
private fun AlarmListSectionPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmListSection(
            sectionTitle = "Upcoming",
            alarms = previewAlarms,
            enabledStates = emptyMap(),
            onToggle = { _, _ -> },
            onClick = {},
            onDelete = {}
        )
    }
}

@ChronirThemePreview
@Composable
private fun AlarmListSectionLazyPreview() {
    ChronirTheme(dynamicColor = false) {
        LazyColumn {
            alarmListSection(
                sectionTitle = "Upcoming",
                alarms = previewAlarms,
                enabledStates = mapOf(previewAlarms.last().id to false),
                onToggle = { _, _ -> },
                onClick = {},
                onDelete = {}
            )
        }
    }
}
