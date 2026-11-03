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
                    .chronirFont(.titleSmall)
                    .foregroundStyle(template.category.color)
                    .frame(width: SpacingTokens.xl, height: SpacingTokens.xl)
                    .background(template.category.color.opacity(0.12), in: .circle)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    ChronirText(template.title, style: .bodyPrimary)
                    ChronirText(
                        template.intervalDescription,
                        style: .bodySmall,
                        color: ColorTokens.textSecondary
                    )
                }

                Spacer()
            }
            .padding(SpacingTokens.md)
            .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: RadiusTokens.md))
            .contentShape(.rect(cornerRadius: RadiusTokens.md))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Fills in the new alarm with this template")
    }
}

#Preview("Light") {
    TemplateLibraryView { _ in }
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    TemplateLibraryView { _ in }
        .preferredColorScheme(.dark)
}
