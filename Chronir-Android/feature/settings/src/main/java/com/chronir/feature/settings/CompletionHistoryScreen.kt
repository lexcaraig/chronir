package com.chronir.feature.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.CompletionStatusBadge
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.util.rememberTimeFormatter
import com.chronir.model.CompletionAction
import com.chronir.model.CompletionRecord
import com.chronir.services.StreakInfo
import java.time.ZoneId

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CompletionHistoryScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: CompletionHistoryViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Completion History") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        modifier = modifier
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier.padding(innerPadding),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(SpacingTokens.Default),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
        ) {
            item {
                StreakCard(streakInfo = uiState.streakInfo)
                Spacer(Modifier.height(SpacingTokens.Medium))
                ChronirText(
                    text = "Recent Activity",
                    style = ChronirTextStyle.TitleSmall,
                    modifier = Modifier.padding(bottom = SpacingTokens.Small)
                )
            }

            if (uiState.records.isEmpty()) {
                item {
                    ChronirText(
                        text = "No completion history yet",
                        style = ChronirTextStyle.BodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(SpacingTokens.Large)
                    )
                }
            } else {
                items(uiState.records, key = { it.id }) { record ->
                    CompletionRecordRow(
                        record = record,
                        alarmTitle = uiState.alarmTitles[record.alarmId]
                    )
                }
            }
        }
    }
}

@Composable
private fun StreakCard(streakInfo: StreakInfo) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(RadiusTokens.Lg)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(SpacingTokens.Large),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            StatColumn("Current\nStreak", "${streakInfo.currentStreak}")
            StatColumn("Longest\nStreak", "${streakInfo.longestStreak}")
            StatColumn("Total", "${streakInfo.totalCompletions}")
            StatColumn("Rate", "${(streakInfo.completionRate * 100).toInt()}%")
        }
    }
}

@Composable
private fun StatColumn(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        ChronirText(
            text = value,
            style = ChronirTextStyle.HeadlineSmall,
            color = MaterialTheme.colorScheme.onPrimaryContainer
        )
        ChronirText(
            text = label,
            style = ChronirTextStyle.LabelSmall,
            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
        )
    }
}

@Composable
private fun CompletionRecordRow(record: CompletionRecord, alarmTitle: String?) {
    // Locale- and 12/24-hour-aware, e.g. "Nov 3, 8:00 PM" or "3 Nov, 20:00".
    val dateFormatter = rememberTimeFormatter(dateSkeleton = "MMMd")

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(RadiusTokens.Md)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(SpacingTokens.Medium),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                ChronirText(
                    text = alarmTitle ?: "Deleted alarm",
                    style = ChronirTextStyle.BodyMedium,
                    color = if (alarmTitle == null) {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    }
                )
                ChronirText(
                    text = record.timestamp.atZone(ZoneId.systemDefault()).format(dateFormatter),
                    style = ChronirTextStyle.BodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Spacer(Modifier.width(SpacingTokens.Small))
            CompletionStatusBadge(action = record.action)
        }
    }
}

@ChronirPreview
@Composable
private fun CompletionRecordRowPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Default)) {
            StreakCard(streakInfo = StreakInfo(3, 5, 12, 0.8f))
            Spacer(Modifier.height(SpacingTokens.Small))
            CompletionRecordRow(
                record = CompletionRecord(alarmId = "a", userId = "", action = CompletionAction.COMPLETED),
                alarmTitle = "Pay Rent"
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            CompletionRecordRow(
                record = CompletionRecord(alarmId = "b", userId = "", action = CompletionAction.MISSED),
                alarmTitle = null
            )
        }
    }
}
