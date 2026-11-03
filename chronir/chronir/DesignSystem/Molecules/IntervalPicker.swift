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
                .accessibilityAddTraits(.isHeader)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    ForEach(options) { option in
                        ChronirChip(option.displayName, isSelected: selection == option) {
                            selection = option
                        }
                    }
                }
            }
        }
    }
}

private struct IntervalPickerPreview: View {
    @State var selected: CycleType
    var options: [CycleType] = [.weekly, .monthlyDate, .annual]

    var body: some View {
        IntervalPicker(selection: $selected, options: options)
            .padding()
    }
}

#Preview("Light") {
    IntervalPickerPreview(selected: .weekly)
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark — All Options") {
    DarkPreview { IntervalPickerPreview(selected: .monthlyDate, options: CycleType.allCases) }
}
