package com.chronir.feature.alarmdetail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.CompletionStatusBadge
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.chronirColors
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.util.rememberTimeFormatter
import com.chronir.feature.alarmcreation.AlarmEditorForm
import com.chronir.feature.alarmcreation.EditorMessageEffect
import com.chronir.model.CompletionAction
import com.chronir.model.CompletionRecord
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmDetailScreen(
    onDismiss: () -> Unit,
    onNavigateToPaywall: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showDeleteConfirmation by rememberSaveable { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(uiState.saveSuccess) {
        if (uiState.saveSuccess) onDismiss()
    }

    EditorMessageEffect(
        message = uiState.message,
        snackbarHostState = snackbarHostState,
        onUpgrade = onNavigateToPaywall,
        onShown = viewModel::messageShown
    )

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = { Text("Edit Alarm") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    if (!uiState.isLoading && !uiState.notFound) {
                        IconButton(onClick = { showDeleteConfirmation = true }) {
                            Icon(
                                Icons.Filled.Delete,
                                contentDescription = "Delete alarm",
                                tint = MaterialTheme.colorScheme.error
                            )
                        }
                        TextButton(onClick = viewModel::saveAlarm, enabled = !uiState.isSaving) {
                            Text("Save")
                        }
                    }
                }
            )
        }
    ) { innerPadding ->
        when {
            uiState.isLoading -> Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
            uiState.notFound -> Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                ChronirText(text = "This alarm no longer exists.", style = ChronirTextStyle.BodyLarge)
            }
            else -> AlarmEditorForm(
                form = uiState.form,
                isPlusTier = uiState.isPlusTier,
                onEvent = viewModel::onFormEvent,
                onLockedFeature = onNavigateToPaywall,
                titleError = uiState.titleError,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = SpacingTokens.Default),
                header = {
                    if (uiState.isPendingConfirmation) {
                        PendingConfirmationBanner(onConfirm = viewModel::confirmPending)
                    }
                    AlarmToggleRow(
                        title = "Enabled",
                        subtitle = if (uiState.isEnabled) "Alarm is active" else "Alarm won't fire",
                        isEnabled = uiState.isEnabled,
                        onToggle = viewModel::toggleEnabled
                    )
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                },
                footer = {
                    if (uiState.completionHistory.isNotEmpty()) {
                        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                        CompletionHistorySection(
                            completionCount = uiState.completionCount,
                            history = uiState.completionHistory.take(10)
                        )
                    }
                }
            )
        }
    }

    if (showDeleteConfirmation) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmation = false },
            title = { Text("Delete Alarm") },
            text = { Text("Delete \"${uiState.form.title}\"? This can't be undone.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDeleteConfirmation = false
                        viewModel.deleteAlarm()
                    }
                ) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirmation = false }) { Text("Cancel") }
            }
        )
    }
}

@Composable
private fun PendingConfirmationBanner(onConfirm: () -> Unit) {
    Surface(
        color = MaterialTheme.colorScheme.secondaryContainer,
        contentColor = MaterialTheme.colorScheme.onSecondaryContainer,
        shape = MaterialTheme.shapes.medium,
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(SpacingTokens.Medium),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
        ) {
            ChronirText(
                text = "Did you complete this?",
                style = ChronirTextStyle.TitleSmall,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            ChronirText(
                text = "The last occurrence is waiting for confirmation.",
                style = ChronirTextStyle.BodyMedium,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            ChronirButton(text = "Mark as Done", onClick = onConfirm, modifier = Modifier.fillMaxWidth())
        }
    }
}

@Composable
private fun CompletionHistorySection(
    completionCount: Int,
    history: List<CompletionRecord>
) {
    val locale = LocalConfiguration.current.locales[0] ?: Locale.getDefault()
    val timeFormatter = rememberTimeFormatter()
    val dateFormatter = remember(locale) { DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM).withLocale(locale) }

    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            ChronirText(text = "History", style = ChronirTextStyle.TitleSmall)
            ChronirText(
                text = if (completionCount == 1) "1 completion" else "$completionCount completions",
                style = ChronirTextStyle.BodySmall,
                color = MaterialTheme.chronirColors.textSecondary
            )
        }
        history.forEach { record ->
            val time = record.timestamp.atZone(ZoneId.systemDefault())
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = SpacingTokens.XSmall),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                CompletionStatusBadge(action = record.action)
                ChronirText(
                    text = "${time.format(dateFormatter)}, ${time.format(timeFormatter)}",
                    style = ChronirTextStyle.BodySmall,
                    color = MaterialTheme.chronirColors.textSecondary
                )
            }
        }
    }
}

@ChronirPreview
@Composable
private fun CompletionHistorySectionPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface {
            Column(modifier = Modifier.padding(SpacingTokens.Default)) {
                PendingConfirmationBanner(onConfirm = {})
                CompletionHistorySection(
                    completionCount = 1,
                    history = listOf(
                        CompletionRecord(alarmId = "a", userId = "", action = CompletionAction.COMPLETED, timestamp = Instant.now()),
                        CompletionRecord(alarmId = "a", userId = "", action = CompletionAction.MISSED, timestamp = Instant.now())
                    )
                )
            }
        }
    }
}
