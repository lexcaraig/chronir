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
        } label: {
            HStack(spacing: SpacingTokens.xxs) {
                Image(systemName: "xmark.circle")
                    .font(TypographyTokens.labelSmall)
                Text("None")
                    .font(TypographyTokens.labelLarge)
            }
            .foregroundStyle(selection == nil ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .glassEffect(
                selection == nil
                    ? GlassTokens.element.tint(ColorTokens.primary).interactive()
                    : GlassTokens.element,
                in: .capsule
            )
        }
    }

    private func categoryButton(_ category: AlarmCategory) -> some View {
        Button {
            selection = category
        } label: {
            HStack(spacing: SpacingTokens.xxs) {
                Image(systemName: category.iconName)
                    .font(TypographyTokens.labelSmall)
                Text(category.displayName)
                    .font(TypographyTokens.labelLarge)
            }
            .foregroundStyle(selection == category ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .glassEffect(
                selection == category
                    ? GlassTokens.element.tint(category.color).interactive()
                    : GlassTokens.element,
                in: .capsule
            )
        }
    }
}

#Preview {
    @Previewable @State var selection: AlarmCategory? = .home
    ChronirCategoryPicker(selection: $selection)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
