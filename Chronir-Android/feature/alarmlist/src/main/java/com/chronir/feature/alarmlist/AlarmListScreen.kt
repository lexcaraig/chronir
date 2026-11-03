package com.chronir.feature.alarmlist

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.organisms.EmptyStateView
import com.chronir.designsystem.organisms.alarmListSection
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalTime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmListScreen(
    modifier: Modifier = Modifier,
    onNavigateToCreation: () -> Unit = {},
    onNavigateToDetail: (String) -> Unit = {},
    onNavigateToPaywall: () -> Unit = {},
    viewModel: AlarmListViewModel = hiltViewModel()
) {
    val activeAlarms by viewModel.activeAlarms.collectAsStateWithLifecycle()
    val archivedAlarms by viewModel.archivedAlarms.collectAsStateWithLifecycle()
    val selectedCategory by viewModel.selectedCategory.collectAsStateWithLifecycle()
    val groupByCategory by viewModel.groupByCategory.collectAsStateWithLifecycle()
    val canCreateAlarm by viewModel.canCreateAlarm.collectAsStateWithLifecycle()
    var showArchived by rememberSaveable { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    // Free tier: check the 3-alarm limit before the form opens, not after it's filled in.
    val startCreation: () -> Unit = {
        if (canCreateAlarm) {
            onNavigateToCreation()
        } else {
            scope.launch {
                val result = snackbarHostState.showSnackbar(
                    message = "Free includes ${AlarmListViewModel.FREE_TIER_ALARM_LIMIT} alarms.",
                    actionLabel = "Upgrade",
                    duration = SnackbarDuration.Long
                )
                if (result == SnackbarResult.ActionPerformed) onNavigateToPaywall()
            }
        }
    }

    val deleteWithUndo: (Alarm) -> Unit = { alarm ->
        viewModel.deleteAlarm(alarm)
        scope.launch {
            snackbarHostState.currentSnackbarData?.dismiss()
            val result = snackbarHostState.showSnackbar(
                message = "\"${alarm.title}\" deleted",
                actionLabel = "Undo",
                duration = SnackbarDuration.Long
            )
            if (result == SnackbarResult.ActionPerformed) viewModel.restoreAlarm(alarm)
        }
    }

    val enabledStates = remember(activeAlarms) { activeAlarms.associate { it.id to it.isEnabled } }
    val archivedEnabledStates = remember(archivedAlarms) { archivedAlarms.associate { it.id to it.isEnabled } }
    val activeSections = remember(activeAlarms, groupByCategory) {
        if (groupByCategory) {
            activeAlarms
                .groupBy { AlarmCategory.fromColorTag(it.colorTag) }
                .toList()
                .sortedBy { (category, _) -> category?.ordinal ?: Int.MAX_VALUE }
                .map { (category, alarms) -> (category?.displayName ?: "Uncategorized") to alarms }
        } else {
            listOf("Upcoming" to activeAlarms)
        }
    }

    val isEmpty = activeAlarms.isEmpty() && archivedAlarms.isEmpty() && selectedCategory == null

    SingleColumnTemplate(
        title = "Alarms",
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackbarHostState) },
        contentPadding = if (isEmpty) PaddingValues() else PaddingValues(bottom = SpacingTokens.Large),
        lazyContent = {
            if (isEmpty) {
                item(key = "empty-state") {
                    EmptyStateView(onCreateAlarm = startCreation, modifier = Modifier.fillParentMaxSize())
                }
                return@SingleColumnTemplate
            }

            item(key = "category-filter") {
                CategoryFilterRow(
                    selectedCategory = selectedCategory,
                    onSelect = viewModel::selectCategory
                )
            }

            if (activeAlarms.isEmpty() && archivedAlarms.isEmpty()) {
                item(key = "empty-category") {
                    ChronirText(
                        text = "No alarms in this category",
                        style = ChronirTextStyle.BodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(SpacingTokens.Large)
                    )
                }
            }

            activeSections.forEach { (title, alarms) ->
                if (alarms.isNotEmpty()) {
                    alarmListSection(
                        sectionTitle = title,
                        alarms = alarms,
                        enabledStates = enabledStates,
                        onToggle = { alarm, _ -> viewModel.toggleAlarm(alarm) },
                        // Pending cards open the detail screen, which offers "Mark as Done".
                        onClick = { alarm -> onNavigateToDetail(alarm.id) },
                        onDelete = deleteWithUndo,
                        keyPrefix = "active-$title"
                    )
                }
            }

            if (archivedAlarms.isNotEmpty()) {
                item(key = "archived-header") {
                    ArchivedHeader(
                        count = archivedAlarms.size,
                        expanded = showArchived,
                        onToggle = { showArchived = it }
                    )
                }
                if (showArchived) {
                    alarmListSection(
                        sectionTitle = "",
                        alarms = archivedAlarms,
                        enabledStates = archivedEnabledStates,
                        onToggle = { alarm, _ -> viewModel.toggleAlarm(alarm) },
                        onClick = { alarm -> onNavigateToDetail(alarm.id) },
                        onDelete = deleteWithUndo,
                        keyPrefix = "archived"
                    )
                }
            }
        }
    )
}

@Composable
private fun CategoryFilterRow(
    selectedCategory: AlarmCategory?,
    onSelect: (AlarmCategory?) -> Unit
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = SpacingTokens.Default),
        horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small),
        modifier = Modifier.padding(bottom = SpacingTokens.Small)
    ) {
        item {
            FilterChip(
                selected = selectedCategory == null,
                onClick = { onSelect(null) },
                label = { Text("All") }
            )
        }
        items(AlarmCategory.entries) { category ->
            FilterChip(
                selected = selectedCategory == category,
                onClick = { onSelect(category) },
                label = { Text(category.displayName) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                    selectedLabelColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    }
}

@Composable
private fun ArchivedHeader(
    count: Int,
    expanded: Boolean,
    onToggle: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .toggleable(value = expanded, role = Role.Button, onValueChange = onToggle)
            .padding(horizontal = SpacingTokens.Default, vertical = SpacingTokens.Small)
            .semantics(mergeDescendants = true) { heading() },
        verticalAlignment = Alignment.CenterVertically
    ) {
        ChronirText(
            text = "Archived",
            style = ChronirTextStyle.TitleSmall,
            color = MaterialTheme.colorScheme.primary
        )
        ChronirBadge(
            label = "$count",
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(start = SpacingTokens.XSmall)
        )
        Icon(
            imageVector = if (expanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
            contentDescription = if (expanded) "Collapse archived alarms" else "Expand archived alarms",
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(start = SpacingTokens.XSmall)
        )
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
    )
)

@ChronirPreview
@Composable
private fun AlarmListContentPreview() {
    ChronirTheme(dynamicColor = false) {
        LazyColumn {
            item { CategoryFilterRow(selectedCategory = null, onSelect = {}) }
            alarmListSection(
                sectionTitle = "Upcoming",
                alarms = sampleAlarms,
                enabledStates = emptyMap(),
                onToggle = { _, _ -> },
                onClick = {},
                onDelete = {}
            )
            item { ArchivedHeader(count = 2, expanded = false, onToggle = {}) }
        }
    }
}
