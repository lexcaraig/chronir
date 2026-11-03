package com.chronir.designsystem.templates

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.organisms.EmptyStateView
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.SpacingTokens

/**
 * Content column cap for medium/expanded windows (tablets, foldables, landscape). Material's
 * readable single-pane width; on phones it has no effect.
 */
val SingleColumnMaxContentWidth: Dp = 840.dp // token-exempt: Material expanded-width content cap

/** Scaffold + top app bar with a scrolling single column (capped at [maxContentWidth], centered). */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SingleColumnTemplate(
    title: String,
    modifier: Modifier = Modifier,
    floatingActionButton: @Composable () -> Unit = {},
    snackbarHost: @Composable () -> Unit = {},
    maxContentWidth: Dp = SingleColumnMaxContentWidth,
    content: @Composable () -> Unit
) {
    SingleColumnScaffold(title, modifier, floatingActionButton, snackbarHost) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentAlignment = Alignment.TopCenter
        ) {
            Column(
                modifier = Modifier
                    .widthIn(max = maxContentWidth)
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                content()
            }
        }
    }
}

/**
 * Lazy variant: [lazyContent] is a `LazyColumn` scope, so long lists are virtualized and items can be
 * keyed/animated (see `alarmListSection`). Use `Modifier.fillParentMaxSize()` on an item to center a
 * full-height state such as [EmptyStateView].
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SingleColumnTemplate(
    title: String,
    lazyContent: LazyListScope.() -> Unit,
    modifier: Modifier = Modifier,
    floatingActionButton: @Composable () -> Unit = {},
    snackbarHost: @Composable () -> Unit = {},
    maxContentWidth: Dp = SingleColumnMaxContentWidth,
    contentPadding: PaddingValues = PaddingValues(bottom = SpacingTokens.Massive)
) {
    SingleColumnScaffold(title, modifier, floatingActionButton, snackbarHost) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentAlignment = Alignment.TopCenter
        ) {
            LazyColumn(
                modifier = Modifier
                    .widthIn(max = maxContentWidth)
                    .fillMaxSize(),
                contentPadding = contentPadding,
                content = lazyContent
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SingleColumnScaffold(
    title: String,
    modifier: Modifier,
    floatingActionButton: @Composable () -> Unit,
    snackbarHost: @Composable () -> Unit,
    body: @Composable (PaddingValues) -> Unit
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = { TopAppBar(title = { Text(text = title) }) },
        snackbarHost = snackbarHost,
        floatingActionButton = floatingActionButton,
        content = body
    )
}

@ChronirThemePreview
@Composable
private fun SingleColumnTemplatePreview() {
    ChronirTheme(dynamicColor = false) {
        SingleColumnTemplate(title = "Settings") {
            ChronirText(
                text = "Content scrolls in a single column, capped at 840dp on wide windows.",
                style = ChronirTextStyle.BodyPrimary,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Medium)
            )
        }
    }
}

@ChronirThemePreview
@Composable
private fun SingleColumnTemplateLazyEmptyPreview() {
    ChronirTheme(dynamicColor = false) {
        SingleColumnTemplate(
            title = "Alarms",
            lazyContent = {
                item { EmptyStateView(onCreateAlarm = {}, modifier = Modifier.fillParentMaxSize()) }
            }
        )
    }
}
