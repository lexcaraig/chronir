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
import com.chronir.designsystem.organisms.AlarmListSection
import com.chronir.designsystem.organisms.EmptyStateView
import com.chronir.designsystem.templates.ModalSheetTemplate
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import java.time.Instant
import java.time.LocalTime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmListScreen(
    modifier: Modifier = Modifier,
    onNavigateToCreation: (() -> Unit)? = null
) {
    var showCreateSheet by remember { mutableStateOf(false) }
    var enabledStates by remember { mutableStateOf<Map<String, Boolean>>(emptyMap()) }
    val alarms = sampleAlarms

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
                onToggle = { alarm, newValue ->
                    enabledStates = enabledStates + (alarm.id to newValue)
                },
                onClick = {},
                onDelete = {}
            )
        }
    }

    if (showCreateSheet) {
        ModalSheetTemplate(onDismiss = { showCreateSheet = false }) {
            // AlarmCreationForm will be wired here in S3-06
            com.chronir.designsystem.atoms.ChronirText(
                text = "Create Alarm (placeholder)",
                style = com.chronir.designsystem.atoms.ChronirTextStyle.HeadlineTitle
            )
        }
    }
}

private val sampleAlarms = listOf(
    Alarm(
        title = "Morning Workout",
        cycleType = CycleType.WEEKLY,
        scheduledTime = LocalTime.of(7, 0),
        nextFireDate = Instant.now().plusSeconds(3600),
        isPersistent = true,
        note = "Don't skip leg day"
    ),
    Alarm(
        title = "Pay Rent",
        cycleType = CycleType.MONTHLY,
        scheduledTime = LocalTime.of(9, 0),
        nextFireDate = Instant.now().minusSeconds(7200)
    ),
    Alarm(
        title = "Annual Checkup",
        cycleType = CycleType.ANNUAL,
        scheduledTime = LocalTime.of(10, 0),
        nextFireDate = Instant.now().plusSeconds(86400)
    )
)

@Preview(showBackground = true)
@Composable
private fun AlarmListScreenPreview() {
    AlarmListScreen()
}
