package com.chronir.feature.alarmcreation

import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
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
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmCreationScreen(
    onDismiss: () -> Unit,
    onNavigateToPaywall: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AlarmCreationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showTemplates by rememberSaveable { mutableStateOf(false) }
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
                title = { Text("New Alarm") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Filled.Close, contentDescription = "Cancel")
                    }
                },
                actions = {
                    TextButton(onClick = viewModel::saveAlarm, enabled = !uiState.isSaving) {
                        Text("Save")
                    }
                }
            )
        }
    ) { innerPadding ->
        AlarmEditorForm(
            form = uiState.form,
            isPlusTier = uiState.isPlusTier,
            onEvent = viewModel::onFormEvent,
            onLockedFeature = onNavigateToPaywall,
            titleError = uiState.titleError,
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                // Edge-to-edge: inner padding already covers the nav bar, so pad only the keyboard's remainder.
                .consumeWindowInsets(innerPadding)
                .imePadding()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Default),
            header = {
                TextButton(onClick = { showTemplates = true }) {
                    Text("Use a template")
                }
            }
        )
    }

    if (showTemplates) {
        TemplateLibrarySheet(
            onDismiss = { showTemplates = false },
            onSelectTemplate = { template ->
                showTemplates = false
                viewModel.loadTemplate(template)
            }
        )
    }
}

/** Shows [message] as a snackbar once; an upgrade message gets an "Upgrade" action. */
@Composable
fun EditorMessageEffect(
    message: EditorMessage?,
    snackbarHostState: SnackbarHostState,
    onUpgrade: () -> Unit,
    onShown: () -> Unit
) {
    LaunchedEffect(message) {
        if (message == null) return@LaunchedEffect
        val result = snackbarHostState.showSnackbar(
            message = message.text,
            actionLabel = if (message.offerUpgrade) "Upgrade" else null,
            withDismissAction = !message.offerUpgrade,
            duration = if (message.offerUpgrade) SnackbarDuration.Long else SnackbarDuration.Short
        )
        onShown()
        if (result == SnackbarResult.ActionPerformed) onUpgrade()
    }
}

@ChronirPreview
@Composable
private fun AlarmCreationFormPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface {
            AlarmEditorForm(
                form = AlarmFormState(title = "Morning Workout"),
                isPlusTier = true,
                onEvent = {},
                onLockedFeature = {},
                modifier = Modifier.padding(SpacingTokens.Default)
            )
        }
    }
}
