package com.chronir.feature.settings

/**
 * Minimal Markdown → blocks parser for the in-app FAQ / Privacy / Terms documents.
 * shortcut: covers the syntax those documents use (headings, bullets, rules, tables, paragraphs,
 * inline **bold** and [links](url)); switch to a Markdown library if the documents grow richer.
 */
internal sealed interface MarkdownBlock {
    data class Heading(
        val level: Int,
        val text: String
    ) : MarkdownBlock

    data class Paragraph(
        val text: String
    ) : MarkdownBlock

    data class Bullet(
        val text: String
    ) : MarkdownBlock

    data class TableRow(
        val cells: List<String>,
        val isHeader: Boolean
    ) : MarkdownBlock

    data object Rule : MarkdownBlock
}

// Compiled once: parseMarkdown runs per line and parseInline per rendered block.
private val HeadingRegex = Regex("^(#{1,6})\\s+(.*)$")
private val RuleRegex = Regex("^(-{3,}|\\*{3,}|_{3,})$")
private val TableSeparatorCellRegex = Regex("^:?-+:?$")
private val SafeLinkRegex = Regex("^(https?:|mailto:)", RegexOption.IGNORE_CASE)
private val InlineRegex = Regex("\\*\\*(.+?)\\*\\*|\\[([^\\]]+)]\\(([^)\\s]+)\\)")

internal fun parseMarkdown(source: String): List<MarkdownBlock> {
    val blocks = mutableListOf<MarkdownBlock>()
    val paragraph = mutableListOf<String>()
    var tableRowIndex = 0

    fun flushParagraph() {
        if (paragraph.isNotEmpty()) {
            blocks += MarkdownBlock.Paragraph(paragraph.joinToString("\n"))
            paragraph.clear()
        }
    }

    for (raw in source.lines()) {
        val line = raw.trim()
        val heading = HeadingRegex.find(line)
        when {
            line.isEmpty() -> {
                flushParagraph()
                tableRowIndex = 0
            }
            heading != null -> {
                flushParagraph()
                blocks += MarkdownBlock.Heading(heading.groupValues[1].length, heading.groupValues[2])
            }
            line.matches(RuleRegex) -> {
                flushParagraph()
                blocks += MarkdownBlock.Rule
            }
            line.startsWith("|") -> {
                flushParagraph()
                val cells = line.trim('|').split('|').map { it.trim() }
                // The |---|---| line under a header row carries no content.
                if (cells.all { it.matches(TableSeparatorCellRegex) }) continue
                blocks += MarkdownBlock.TableRow(cells, isHeader = tableRowIndex == 0)
                tableRowIndex++
            }
            line.startsWith("- ") || line.startsWith("* ") -> {
                flushParagraph()
                blocks += MarkdownBlock.Bullet(line.drop(2))
            }
            else -> paragraph += line
        }
    }
    flushParagraph()
    return blocks
}

/** One inline run: plain or bold text, optionally a link target. */
internal data class InlineSpan(
    val text: String,
    val bold: Boolean = false,
    val url: String? = null
)

internal fun parseInline(text: String): List<InlineSpan> {
    val spans = mutableListOf<InlineSpan>()
    var last = 0
    for (match in InlineRegex.findAll(text)) {
        if (match.range.first > last) spans += InlineSpan(text.substring(last, match.range.first))
        val bold = match.groups[1]
        spans += if (bold != null) {
            InlineSpan(bold.value, bold = true)
        } else {
            // Only web and mail links open; anything else (intent:, file:, custom schemes) stays plain text.
            val url = match.groupValues[3].takeIf { SafeLinkRegex.containsMatchIn(it) }
            InlineSpan(match.groupValues[2], url = url)
        }
        last = match.range.last + 1
    }
    if (last < text.length) spans += InlineSpan(text.substring(last))
    return spans
}
