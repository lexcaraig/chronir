import SwiftUI

struct IntervalPicker: View {
    @Binding var selection: CycleType
    var options: [CycleType]

    init(
        selection: Binding<CycleType>,
        options: [CycleType] = [.weekly, .monthlyDate, .annual]
    ) {
        self._selection = selection
        self.options = options
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Repeat", style: .labelMedium, color: ColorTokens.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    ForEach(options) { option in
                        Button {
                            selection = option
                        } label: {
                            ChronirText(
                                option.displayName,
                                style: .labelLarge,
                                color: selection == option ? .white : ColorTokens.textSecondary
                            )
                            .padding(.horizontal, SpacingTokens.md)
                            .padding(.vertical, SpacingTokens.sm)
                            .chronirGlassSelectableCapsule(isSelected: selection == option)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Interval Picker") {
    @Previewable @State var selected = CycleType.weekly
    IntervalPicker(selection: $selected)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("All Options") {
    @Previewable @State var selected = CycleType.monthlyDate
    IntervalPicker(
        selection: $selected,
        options: CycleType.allCases
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
