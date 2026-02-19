import SwiftUI

struct TemplateLibraryView: View {
    let onSelectTemplate: (AlarmTemplate) -> Void
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredTemplates: [AlarmCategory: [AlarmTemplate]] {
        let templates: [AlarmTemplate]
        if searchText.isEmpty {
            templates = AlarmTemplate.all
        } else {
            let query = searchText.lowercased()
            templates = AlarmTemplate.all.filter {
                $0.title.lowercased().contains(query)
                    || $0.category.displayName.lowercased().contains(query)
                    || $0.suggestedNote.lowercased().contains(query)
            }
        }
        return Dictionary(grouping: templates, by: \.category)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: SpacingTokens.lg) {
                    ForEach(AlarmTemplate.templateCategories, id: \.self) { category in
                        if let templates = filteredTemplates[category], !templates.isEmpty {
                            categorySection(category: category, templates: templates)
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xl)
            }
            .background(ColorTokens.backgroundPrimary)
            .searchable(text: $searchText, prompt: "Search templates")
            .navigationTitle("Templates")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
    }

    private func categorySection(category: AlarmCategory, templates: [AlarmTemplate]) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.sm) {
                Image(systemName: category.iconName)
                    .foregroundStyle(category.color)
                ChronirText(category.displayName, style: .labelLarge)
            }
            .padding(.top, SpacingTokens.sm)

            ForEach(templates) { template in
                templateRow(template)
            }
        }
    }

    private func templateRow(_ template: AlarmTemplate) -> some View {
        Button {
            onSelectTemplate(template)
            dismiss()
        } label: {
            HStack(spacing: SpacingTokens.md) {
                Image(systemName: template.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(template.category.color)
                    .frame(width: 36, height: 36)
                    .background(template.category.color.opacity(0.12), in: .circle)

                VStack(alignment: .leading, spacing: 2) {
                    ChronirText(template.title, style: .bodyPrimary)
                    ChronirText(
                        template.intervalDescription,
                        style: .caption,
                        color: ColorTokens.textSecondary
                    )
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .padding(SpacingTokens.md)
            .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: RadiusTokens.md))
        }
    }
}

#Preview {
    TemplateLibraryView { _ in
        // Preview action
    }
}
