package com.chronir.feature.settings

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withLink
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL

/** `url` with this prefix names a file in the module's assets instead of a web address. */
internal const val ASSET_PREFIX = "asset:"

/** Renders a Markdown document (FAQ, Privacy, Terms) natively, from a bundled asset or its raw URL. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LegalDocumentScreen(
    title: String,
    url: String,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    var blocks by remember(url) { mutableStateOf<List<MarkdownBlock>?>(null) }
    var failed by remember(url) { mutableStateOf(false) }
    var attempt by remember(url) { mutableIntStateOf(0) }
    val assets = LocalContext.current.assets

    LaunchedEffect(url, attempt) {
        failed = false
        blocks = null
        runCatching {
            withContext(Dispatchers.IO) {
                val text = if (url.startsWith(ASSET_PREFIX)) {
                    assets.open(url.removePrefix(ASSET_PREFIX)).bufferedReader().use { it.readText() }
                } else {
                    fetchText(url)
                }
                parseMarkdown(text)
            }
        }
            .onSuccess { blocks = it }
            .onFailure { failed = true }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(title) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        modifier = modifier
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentAlignment = Alignment.TopCenter
        ) {
            val loaded = blocks
            when {
                failed -> LoadError(title = title, onRetry = { attempt++ })
                loaded == null -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                else -> MarkdownDocument(loaded)
            }
        }
    }
}

private fun fetchText(url: String): String {
    val connection = URL(url).openConnection() as HttpURLConnection
    connection.connectTimeout = 15_000
    connection.readTimeout = 15_000
    return try {
        check(connection.responseCode == HttpURLConnection.HTTP_OK) { "HTTP ${connection.responseCode}" }
        connection.inputStream.bufferedReader().use { it.readText() }
    } finally {
        connection.disconnect()
    }
}

@Composable
private fun LoadError(title: String, onRetry: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(SpacingTokens.Large),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Couldn't load $title",
            style = MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurface
        )
        Text(
            text = "Check your connection and try again.",
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = SpacingTokens.Small, bottom = SpacingTokens.Large)
        )
        OutlinedButton(onClick = onRetry) { Text("Try again") }
    }
}

@Composable
private fun MarkdownDocument(blocks: List<MarkdownBlock>) {
    val typography = MaterialTheme.typography
    val onSurface = MaterialTheme.colorScheme.onSurface
    LazyColumn(
        modifier = Modifier
            .fillMaxWidth()
            .widthIn(max = SpacingTokens.MaxContentWidth),
        contentPadding = PaddingValues(horizontal = SpacingTokens.Default, vertical = SpacingTokens.Medium)
    ) {
        itemsIndexed(blocks) { index, block ->
            val top = if (index == 0) SpacingTokens.None else SpacingTokens.Small
            when (block) {
                is MarkdownBlock.Heading -> Text(
                    text = inline(block.text),
                    style = when (block.level) {
                        1 -> typography.headlineSmall
                        2 -> typography.titleLarge
                        else -> typography.titleMedium
                    },
                    color = onSurface,
                    modifier = Modifier
                        .padding(top = if (index == 0) SpacingTokens.None else SpacingTokens.Large)
                        .semantics { heading() }
                )
                is MarkdownBlock.Paragraph -> BodyText(inline(block.text), typography.bodyLarge, top)
                is MarkdownBlock.Bullet -> Row(modifier = Modifier.padding(top = SpacingTokens.XSmall)) {
                    Text(text = "•", style = typography.bodyLarge, color = onSurface)
                    BodyText(
                        inline(block.text),
                        typography.bodyLarge,
                        SpacingTokens.None,
                        Modifier.padding(start = SpacingTokens.Small)
                    )
                }
                is MarkdownBlock.TableRow -> BodyText(
                    inline(block.cells.joinToString("  ·  ")),
                    if (block.isHeader) typography.labelLarge else typography.bodyMedium,
                    SpacingTokens.XSmall
                )
                MarkdownBlock.Rule -> HorizontalDivider(
                    modifier = Modifier.padding(vertical = SpacingTokens.Medium),
                    color = MaterialTheme.colorScheme.outlineVariant
                )
            }
        }
    }
}

@Composable
private fun BodyText(
    text: AnnotatedString,
    style: TextStyle,
    top: androidx.compose.ui.unit.Dp,
    modifier: Modifier = Modifier
) {
    Text(
        text = text,
        style = style,
        color = MaterialTheme.colorScheme.onSurface,
        modifier = modifier.padding(top = top)
    )
}

@Composable
private fun inline(text: String): AnnotatedString {
    val linkStyles = TextLinkStyles(
        style = SpanStyle(color = MaterialTheme.colorScheme.primary, textDecoration = TextDecoration.Underline)
    )
    return buildAnnotatedString {
        parseInline(text).forEach { span ->
            when {
                span.url != null -> withLink(LinkAnnotation.Url(span.url, linkStyles)) { append(span.text) }
                span.bold -> withStyle(SpanStyle(fontWeight = FontWeight.SemiBold)) { append(span.text) }
                else -> append(span.text)
            }
        }
    }
}

private const val PREVIEW_MARKDOWN = """# Chronir FAQ

## General

**What is Chronir?**
A high-persistence alarm app for long-cycle tasks.

- Weekly, monthly and annual cycles
- Read our [Privacy Policy](https://example.com)

---

| Feature | Free | Plus |
|---|---|---|
| Alarms | 3 | Unlimited |
"""

@Preview(name = "Light", showBackground = true)
@Preview(name = "Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun MarkdownDocumentPreview() {
    ChronirTheme(dynamicColor = false) {
        androidx.compose.material3.Surface { MarkdownDocument(parseMarkdown(PREVIEW_MARKDOWN)) }
    }
}

@Preview(name = "Error — Light", showBackground = true)
@Preview(name = "Error — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun LoadErrorPreview() {
    ChronirTheme(dynamicColor = false) {
        androidx.compose.material3.Surface { LoadError(title = "FAQ", onRetry = {}) }
    }
}
