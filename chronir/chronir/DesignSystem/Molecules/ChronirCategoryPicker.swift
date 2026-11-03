import SwiftUI

struct ChronirCategoryPicker: View {
    @Binding var selection: AlarmCategory?

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Category", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityAddTraits(.isHeader)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    ChronirChip(
                        "None",
                        systemImage: "xmark.circle",
                        isSelected: selection == nil,
                        accessibilityLabel: "No category"
                    ) {
                        select(nil)
                    }
                    ForEach(AlarmCategory.allCases) { category in
                        let pair = ChronirBadge.pair(for: category)
                        ChronirChip(
                            category.displayName,
                            systemImage: category.iconName,
                            isSelected: selection == category,
                            tint: pair.background,
                            selectedForeground: pair.foreground
                        ) {
                            select(category)
                        }
                    }
                }
            }
        }
    }

    private func select(_ category: AlarmCategory?) {
        selection = category
        #if os(iOS)
        if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
        #endif
    }
}

private struct CategoryPickerPreview: View {
    @State var selection: AlarmCategory?

    var body: some View {
        ChronirCategoryPicker(selection: $selection)
            .padding()
    }
}

#Preview("Light") {
    CategoryPickerPreview(selection: .home)
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { CategoryPickerPreview(selection: .vehicle) }
}
