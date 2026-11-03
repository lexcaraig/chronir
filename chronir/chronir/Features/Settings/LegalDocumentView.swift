import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let rawURL: URL

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
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
                    ChronirText("Couldn't load \(title)", style: .titleSmall, alignment: .center)
                    ChronirText(
                        "Check your connection and try again.",
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary,
                        alignment: .center
                    )
                    ChronirButton("Try Again", style: .secondary) {
                        Task { await fetchDocument() }
                    }
                }
                .padding(SpacingTokens.lg)
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
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>\(generateCSS())</style>
        </head>
        <body>\(html)</body>
        </html>
        """
    }

    /// CSS built from the app's color tokens for the current appearance, so legal pages follow the theme
    /// and the single app tint. Text uses `-apple-system-body`, so WebKit follows Dynamic Type; the in-app
    /// text-size preference multiplies on top. Pinch-zoom stays enabled.
    private func generateCSS() -> String {
        let text = cssHex(ColorTokens.textPrimary)
        let secondary = cssHex(ColorTokens.textSecondary)
        let link = cssHex(ColorTokens.primary)
        let border = cssHex(ColorTokens.borderDefault)
        let headerFill = cssHex(ColorTokens.surfaceCard)
        return """
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { font: -apple-system-body; }
        body {
            font-size: \(Int((textSizeScale * 100).rounded()))%;
            line-height: 1.6;
            color: \(text);
            background: transparent;
            padding: 1em;
            overflow-wrap: break-word;
        }
        h1, h2, h3, h4 { color: \(text); line-height: 1.25; }
        h1 { font-size: 1.75em; font-weight: 700; margin: 1.5em 0 0.75em; }
        h2 { font-size: 1.375em; font-weight: 600; margin: 1.25em 0 0.625em; }
        h3 { font-size: 1.125em; font-weight: 600; margin: 1em 0 0.5em; }
        h4 { font-size: 1em; font-weight: 600; margin: 0.75em 0 0.375em; }
        p { margin: 0.5em 0; }
        a { color: \(link); text-decoration: underline; text-underline-offset: 0.15em; }
        ul, ol { padding-left: 1.5em; margin: 0.5em 0; }
        li { margin: 0.25em 0; }
        hr { border: none; border-top: 1px solid \(border); margin: 1em 0; }
        table { width: 100%; border-collapse: collapse; margin: 0.75em 0; font-size: 0.875em; }
        th, td { padding: 0.5em 0.75em; text-align: left; border: 1px solid \(border); }
        th { background: \(headerFill); font-weight: 600; }
        blockquote { border-left: 3px solid \(border); padding-left: 0.75em; margin: 0.5em 0; color: \(secondary); }
        """
    }

    /// Resolves a token for the view's current appearance and contrast setting as `#RRGGBB`.
    private func cssHex(_ color: Color) -> String {
        let traits = UITraitCollection { traits in
            traits.userInterfaceStyle = colorScheme == .dark ? .dark : .light
            traits.accessibilityContrast = colorSchemeContrast == .increased ? .high : .normal
        }
        let resolved = UIColor(color).resolvedColor(with: traits)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        func byte(_ value: CGFloat) -> Int { Int((min(max(value, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", byte(red), byte(green), byte(blue))
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
        // Escape first so downloaded text can never inject markup; the rules below add the only tags.
        var result = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
        // Bold: **text**
        result = result.replacingOccurrences(
            of: #"\*\*(.+?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        // Links: [text](url) — web and mail only; any other scheme keeps just its text.
        result = result.replacingOccurrences(
            of: #"\[(.+?)\]\(((?:https?|mailto):[^()\[\]\s]+)\)"#,
            with: "<a href=\"$2\">$1</a>",
            options: [.regularExpression, .caseInsensitive]
        )
        result = result.replacingOccurrences(
            of: #"\[(.+?)\]\((.+?)\)"#,
            with: "$1",
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

#Preview("Light") {
    NavigationStack {
        LegalDocumentView(
            title: "Privacy Policy",
            // swiftlint:disable:next force_unwrapping
            rawURL: URL(string: "https://gist.githubusercontent.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c/raw/")!
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        LegalDocumentView(
            title: "Privacy Policy",
            // swiftlint:disable:next force_unwrapping
            rawURL: URL(string: "https://gist.githubusercontent.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c/raw/")!
        )
    }
    .preferredColorScheme(.dark)
}
