package com.chronir.feature.settings

import org.junit.Assert.assertEquals
import org.junit.Test

class MarkdownBlocksTest {
    @Test
    fun parsesHeadingsParagraphsBulletsRulesAndTables() {
        val blocks = parseMarkdown(
            """
            # Title
            ## Section

            **Q?**
            Answer line.

            - one
            * two
            ---
            | Feature | Free |
            |---|---|
            | Alarms | 3 |
            """.trimIndent()
        )
        assertEquals(
            listOf(
                MarkdownBlock.Heading(1, "Title"),
                MarkdownBlock.Heading(2, "Section"),
                MarkdownBlock.Paragraph("**Q?**\nAnswer line."),
                MarkdownBlock.Bullet("one"),
                MarkdownBlock.Bullet("two"),
                MarkdownBlock.Rule,
                MarkdownBlock.TableRow(listOf("Feature", "Free"), isHeader = true),
                MarkdownBlock.TableRow(listOf("Alarms", "3"), isHeader = false)
            ),
            blocks
        )
    }

    @Test
    fun parsesBoldAndLinksInline() {
        assertEquals(
            listOf(
                InlineSpan("Read "),
                InlineSpan("this", bold = true),
                InlineSpan(" and our "),
                InlineSpan("Privacy Policy", url = "https://example.com/p"),
                InlineSpan(".")
            ),
            parseInline("Read **this** and our [Privacy Policy](https://example.com/p).")
        )
    }

    @Test
    fun unsafeLinkSchemesRenderAsPlainText() {
        val spans = parseInline("[x](intent://evil) [y](mailto:a@b.c)")
        assertEquals(null, spans.first { it.text == "x" }.url)
        assertEquals("mailto:a@b.c", spans.first { it.text == "y" }.url)
    }
}
