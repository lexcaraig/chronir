package com.chronir.feature.alarmlist

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.organisms.AlarmListSection
import com.chronir.designsystem.organisms.EmptyStateView
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmListScreen(
    modifier: Modifier = Modifier,
    onNavigateToCreation: () -> Unit = {},
    onNavigateToDetail: (String) -> Unit = {},
    viewModel: AlarmListViewModel = hiltViewModel()
) {
    val activeAlarms by viewModel.activeAlarms.collectAsStateWithLifecycle()
    val archivedAlarms by viewModel.archivedAlarms.collectAsStateWithLifecycle()
    val selectedCategory by viewModel.selectedCategory.collectAsStateWithLifecycle()
    var showArchived by remember { mutableStateOf(false) }

    val enabledStates = remember(activeAlarms) {
        activeAlarms.associate { it.id to it.isEnabled }
    }

    SingleColumnTemplate(
        title = "Alarms",
        modifier = modifier,
        floatingActionButton = {
            if (activeAlarms.isNotEmpty()) {
                FloatingActionButton(
                    onClick = onNavigateToCreation,
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = MaterialTheme.colorScheme.onPrimary
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Create Alarm")
                }
            }
        }
    ) {
        if (activeAlarms.isEmpty() && archivedAlarms.isEmpty() && selectedCategory == null) {
            EmptyStateView(onCreateAlarm = onNavigateToCreation)
        } else {
            // Category filter chips
            LazyRow(
                contentPadding = PaddingValues(horizontal = SpacingTokens.Default),
                horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small),
                modifier = Modifier.padding(bottom = SpacingTokens.Small)
            ) {
                items(AlarmCategory.entries) { category ->
                    FilterChip(
                        selected = selectedCategory == category,
                        onClick = { viewModel.selectCategory(category) },
                        label = { Text(category.displayName) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                            selectedLabelColor = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    )
                }
            }

            if (activeAlarms.isEmpty() && archivedAlarms.isEmpty()) {
                ChronirText(
                    text = "No alarms in this category",
                    style = ChronirTextStyle.BodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(SpacingTokens.Large)
                )
            } else {
                if (activeAlarms.isNotEmpty()) {
                    AlarmListSection(
                        sectionTitle = "Upcoming",
                        alarms = activeAlarms,
                        enabledStates = enabledStates,
                        onToggle = { alarm, _ ->
                            viewModel.toggleAlarm(alarm)
                        },
                        onClick = { alarm ->
                            if (alarm.isPendingConfirmation) {
                                viewModel.confirmPending(alarm)
                            } else {
                                onNavigateToDetail(alarm.id)
                            }
                        },
                        onDelete = { alarm ->
                            viewModel.deleteAlarm(alarm)
                        }
                    )
                }

                // Archived section for completed one-time alarms
                if (archivedAlarms.isNotEmpty()) {
                    Row(
                        modifier = Modifier
                            .clickable { showArchived = !showArchived }
                            .padding(
                                horizontal = SpacingTokens.Default,
                                vertical = SpacingTokens.Small
                            ),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        ChronirText(
                            text = "ARCHIVED",
                            style = ChronirTextStyle.LabelLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        ChronirBadge(
                            label = "${archivedAlarms.size}",
                            containerColor = MaterialTheme.colorScheme.surfaceVariant,
                            modifier = Modifier.padding(start = SpacingTokens.XSmall)
                        )
                        Icon(
                            imageVector = if (showArchived) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                            contentDescription = if (showArchived) "Collapse" else "Expand",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.padding(start = SpacingTokens.XSmall)
                        )
                    }

                    AnimatedVisibility(visible = showArchived) {
                        AlarmListSection(
                            sectionTitle = "",
                            alarms = archivedAlarms,
                            enabledStates = archivedAlarms.associate { it.id to it.isEnabled },
                            onToggle = { alarm, _ -> viewModel.toggleAlarm(alarm) },
                            onClick = { alarm -> onNavigateToDetail(alarm.id) },
                            onDelete = { alarm -> viewModel.deleteAlarm(alarm) }
                        )
                    }
                }
            }
        }
    }
}

// Sample alarms kept for preview only
private val sampleAlarms = listOf(
    Alarm(
        title = "Morning Workout",
        cycleType = CycleType.WEEKLY,
        timeOfDay = LocalTime.of(7, 0),
        schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
        nextFireDate = Instant.now().plusSeconds(3600),
        persistenceLevel = PersistenceLevel.FULL,
        note = "Don't skip leg day"
    ),
    Alarm(
        title = "Pay Rent",
        cycleType = CycleType.MONTHLY_DATE,
        timeOfDay = LocalTime.of(9, 0),
        schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
        nextFireDate = Instant.now().minusSeconds(7200)
    ),
    Alarm(
        title = "Annual Checkup",
        cycleType = CycleType.ANNUAL,
        timeOfDay = LocalTime.of(10, 0),
        schedule = Schedule.Annual(month = 3, dayOfMonth = 15, interval = 1),
        nextFireDate = Instant.now().plusSeconds(86400)
    )
)

@Preview(showBackground = true)
@Composable
private fun AlarmListScreenPreview() {
    SingleColumnTemplate(title = "Alarms") {
        AlarmListSection(
            sectionTitle = "Upcoming",
            alarms = sampleAlarms,
            enabledStates = emptyMap(),
            onToggle = { _, _ -> },
            onClick = {},
            onDelete = {}
        )
    }
}
