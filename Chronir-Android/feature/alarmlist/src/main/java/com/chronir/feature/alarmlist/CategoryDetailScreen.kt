package com.chronir.feature.alarmlist

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.organisms.AlarmCard
import com.chronir.designsystem.organisms.AlarmVisualState
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.AlarmCategory
import java.time.Instant

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryDetailScreen(
    category: String,
    onBack: () -> Unit,
    onNavigateToDetail: (String) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: CategoryDetailViewModel = hiltViewModel()
) {
    val alarms by viewModel.alarms.collectAsStateWithLifecycle()
    val alarmCategory = AlarmCategory.entries.firstOrNull { it.name == category }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    ChronirText(
                        text = alarmCategory?.displayName ?: "Category",
                        style = ChronirTextStyle.TitleMedium
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        },
        modifier = modifier
    ) { innerPadding ->
        val filteredAlarms = remember(alarms, category) {
            alarms.filter { AlarmCategory.fromColorTag(it.colorTag)?.name == category }
        }

        if (filteredAlarms.isEmpty()) {
            ChronirText(
                text = "No alarms in this category",
                style = ChronirTextStyle.BodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(innerPadding).padding(SpacingTokens.Large)
            )
        } else {
            LazyColumn(
                modifier = Modifier.padding(innerPadding),
                contentPadding = PaddingValues(SpacingTokens.Default),
                verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
            ) {
                items(filteredAlarms, key = { it.id }) { alarm ->
                    val visualState = when {
                        !alarm.isEnabled -> AlarmVisualState.Inactive
                        alarm.snoozeCount > 0 -> AlarmVisualState.Snoozed
                        alarm.nextFireDate.isBefore(Instant.now()) && alarm.isEnabled -> AlarmVisualState.Overdue
                        else -> AlarmVisualState.Active
                    }
                    AlarmCard(
                        alarm = alarm,
                        visualState = visualState,
                        isEnabled = alarm.isEnabled,
                        onToggle = { viewModel.toggleAlarm(alarm) },
                        onClick = { onNavigateToDetail(alarm.id) },
                        onDelete = { viewModel.deleteAlarm(alarm) }
                    )
                }
            }
        }
    }
}
