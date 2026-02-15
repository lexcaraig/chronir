import SwiftUI

struct ChronirCategoryPicker: View {
    @Binding var selection: AlarmCategory?

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Category", style: .labelMedium, color: ColorTokens.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    noneButton
                    ForEach(AlarmCategory.allCases) { category in
                        categoryButton(category)
                    }
                }
            }
        }
    }

    private var noneButton: some View {
        Button {
            selection = nil
            if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
        } label: {
            HStack(spacing: SpacingTokens.xxs) {
                Image(systemName: "xmark.circle")
                    .chronirFont(.labelSmall)
                Text("None")
                    .chronirFont(.labelLarge)
            }
            .foregroundStyle(selection == nil ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .chronirGlassSelectableCapsule(isSelected: selection == nil)
        }
    }

    private func categoryButton(_ category: AlarmCategory) -> some View {
        Button {
            selection = category
            if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
        } label: {
            HStack(spacing: SpacingTokens.xxs) {
                Image(systemName: category.iconName)
                    .chronirFont(.labelSmall)
                Text(category.displayName)
                    .chronirFont(.labelLarge)
            }
            .foregroundStyle(selection == category ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .chronirGlassSelectableCapsule(isSelected: selection == category, tint: category.color)
        }
    }
}

#Preview {
    @Previewable @State var selection: AlarmCategory? = .home
    ChronirCategoryPicker(selection: $selection)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
