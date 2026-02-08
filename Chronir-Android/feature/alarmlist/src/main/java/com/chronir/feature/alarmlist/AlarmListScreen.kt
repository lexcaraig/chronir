package com.chronir.feature.alarmlist

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.organisms.AlarmListSection
import com.chronir.designsystem.organisms.EmptyStateView
import com.chronir.designsystem.templates.ModalSheetTemplate
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmListScreen(
    modifier: Modifier = Modifier,
    onNavigateToCreation: (() -> Unit)? = null,
    viewModel: AlarmListViewModel = hiltViewModel()
) {
    var showCreateSheet by remember { mutableStateOf(false) }
    val alarms by viewModel.alarms.collectAsStateWithLifecycle()

    // Build enabled states from the alarm list itself
    val enabledStates = remember(alarms) {
        alarms.associate { it.id to it.isEnabled }
    }

    SingleColumnTemplate(
        title = "Alarms",
        modifier = modifier,
        floatingActionButton = {
            if (alarms.isNotEmpty()) {
                FloatingActionButton(
                    onClick = { onNavigateToCreation?.invoke() ?: run { showCreateSheet = true } },
                    containerColor = ColorTokens.Primary,
                    contentColor = ColorTokens.OnPrimary
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Create Alarm")
                }
            }
        }
    ) {
        if (alarms.isEmpty()) {
            EmptyStateView(
                onCreateAlarm = { onNavigateToCreation?.invoke() ?: run { showCreateSheet = true } }
            )
        } else {
            AlarmListSection(
                sectionTitle = "Upcoming",
                alarms = alarms,
                enabledStates = enabledStates,
                onToggle = { alarm, _ ->
                    viewModel.toggleAlarm(alarm)
                },
                onClick = {},
                onDelete = { alarm ->
                    viewModel.deleteAlarm(alarm)
                }
            )
        }
    }

    if (showCreateSheet) {
        ModalSheetTemplate(onDismiss = { showCreateSheet = false }) {
            com.chronir.designsystem.atoms.ChronirText(
                text = "Create Alarm (placeholder)",
                style = com.chronir.designsystem.atoms.ChronirTextStyle.HeadlineTitle
            )
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
    // Preview uses static sample data since ViewModel requires Hilt
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
