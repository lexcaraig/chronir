import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let rawURL: URL

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.textSizeScale) private var textSizeScale

    @State private var markdown: String?
    @State private var error: Error?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let markdown {
                MarkdownWebView(htmlContent: buildHTML(markdown))
            } else {
                VStack(spacing: SpacingTokens.lg) {
                    ChronirText("Unable to load document.", style: .bodyPrimary)
                    ChronirButton("Retry", style: .secondary) {
                        Task { await fetchDocument() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await fetchDocument() }
    }

    private func fetchDocument() async {
        isLoading = true
        error = nil
        do {
            let (data, _) = try await URLSession.shared.data(from: rawURL)
            markdown = String(data: data, encoding: .utf8)
            if markdown == nil { error = URLError(.cannotDecodeContentData) }
        } catch {
            self.error = error
            markdown = nil
        }
        isLoading = false
    }

    // MARK: - HTML Generation

    private func buildHTML(_ md: String) -> String {
        let html = markdownToHTML(md)
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <style>\(generateCSS())</style>
        </head>
        <body>\(html)</body>
        </html>
        """
    }

    private func generateCSS() -> String {
        let scale = textSizeScale
        return """
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, system-ui, sans-serif;
            font-size: \(16 * scale)px;
            line-height: 1.6;
            color: #1E1F21;
            background: transparent;
            padding: \(16 * scale)px;
            -webkit-text-size-adjust: none;
        }
        @media (prefers-color-scheme: dark) {
            body { color: #E2E3E4; }
            h1, h2, h3, h4 { color: #E2E3E4; }
            table { border-color: #303134; }
            th { background: #303134; color: #E2E3E4; }
            td { border-color: #303134; }
            hr { border-color: #303134; }
            a { color: #3B82F6; }
            blockquote { border-color: #303134; color: #96999E; }
        }
        h1 { font-size: \(28 * scale)px; font-weight: 700; margin: \(24 * scale)px 0 \(12 * scale)px; }
        h2 { font-size: \(22 * scale)px; font-weight: 600; margin: \(20 * scale)px 0 \(10 * scale)px; }
        h3 { font-size: \(18 * scale)px; font-weight: 600; margin: \(16 * scale)px 0 \(8 * scale)px; }
        h4 { font-size: \(16 * scale)px; font-weight: 600; margin: \(12 * scale)px 0 \(6 * scale)px; }
        p { margin: \(8 * scale)px 0; }
        a { color: #3B82F6; text-decoration: none; }
        ul, ol { padding-left: \(24 * scale)px; margin: \(8 * scale)px 0; }
        li { margin: \(4 * scale)px 0; }
        hr { border: none; border-top: 1px solid #DDDEE1; margin: \(16 * scale)px 0; }
        table { width: 100%; border-collapse: collapse; margin: \(12 * scale)px 0; font-size: \(14 * scale)px; }
        th, td { padding: \(8 * scale)px \(12 * scale)px; text-align: left; border: 1px solid #DDDEE1; }
        th { background: #F2F2F7; font-weight: 600; }
        blockquote {
            border-left: 3px solid #DDDEE1;
            padding-left: \(12 * scale)px;
            margin: \(8 * scale)px 0;
            color: #6B6E76;
        }
        """
    }

    // MARK: - Markdown Parser

    private func markdownToHTML(_ md: String) -> String {
        var html = ""
        var lines = md.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Table
            if trimmed.hasPrefix("|") && trimmed.hasSuffix("|") {
                html += parseTable(&lines, from: &i)
                continue
            }

            // Horizontal rule
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                html += "<hr>"
                i += 1
                continue
            }

            // Headers
            if let match = trimmed.prefixMatch(of: /^(#{1,4})\s+(.+)/) {
                let level = match.1.count
                html += "<h\(level)>\(processInline(String(match.2)))</h\(level)>"
                i += 1
                continue
            }

            // Unordered list
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                html += "<ul>"
                while i < lines.count {
                    let li = lines[i].trimmingCharacters(in: .whitespaces)
                    guard li.hasPrefix("- ") || li.hasPrefix("* ") else { break }
                    html += "<li>\(processInline(String(li.dropFirst(2))))</li>"
                    i += 1
                }
                html += "</ul>"
                continue
            }

            // Ordered list
            if trimmed.prefixMatch(of: /^\d+\.\s+/) != nil {
                html += "<ol>"
                while i < lines.count {
                    let li = lines[i].trimmingCharacters(in: .whitespaces)
                    guard let m = li.prefixMatch(of: /^\d+\.\s+(.+)/) else { break }
                    html += "<li>\(processInline(String(m.1)))</li>"
                    i += 1
                }
                html += "</ol>"
                continue
            }

            // Blockquote
            if trimmed.hasPrefix("> ") {
                html += "<blockquote>"
                while i < lines.count {
                    let bq = lines[i].trimmingCharacters(in: .whitespaces)
                    guard bq.hasPrefix("> ") else { break }
                    html += "<p>\(processInline(String(bq.dropFirst(2))))</p>"
                    i += 1
                }
                html += "</blockquote>"
                continue
            }

            // Empty line
            if trimmed.isEmpty {
                i += 1
                continue
            }

            // Paragraph
            html += "<p>\(processInline(trimmed))</p>"
            i += 1
        }

        return html
    }

    private func parseTable(_ lines: inout [String], from i: inout Int) -> String {
        var rows: [[String]] = []
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            guard line.hasPrefix("|") && line.hasSuffix("|") else { break }
            let cells = line
                .dropFirst().dropLast()
                .components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            // Skip separator row (e.g. |---|---|)
            if cells.allSatisfy({ $0.allSatisfy({ $0 == "-" || $0 == ":" || $0 == " " }) }) {
                i += 1
                continue
            }
            rows.append(cells)
            i += 1
        }

        guard !rows.isEmpty else { return "" }
        var html = "<table>"
        for (idx, row) in rows.enumerated() {
            let tag = idx == 0 ? "th" : "td"
            html += "<tr>"
            for cell in row {
                html += "<\(tag)>\(processInline(cell))</\(tag)>"
            }
            html += "</tr>"
        }
        html += "</table>"
        return html
    }

    private func processInline(_ text: String) -> String {
        var result = text
        // Bold: **text**
        result = result.replacingOccurrences(
            of: #"\*\*(.+?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        // Links: [text](url)
        result = result.replacingOccurrences(
            of: #"\[(.+?)\]\((.+?)\)"#,
            with: "<a href=\"$2\">$1</a>",
            options: .regularExpression
        )
        // Inline code: `text`
        result = result.replacingOccurrences(
            of: #"`(.+?)`"#,
            with: "<code>$1</code>",
            options: .regularExpression
        )
        return result
    }
}
