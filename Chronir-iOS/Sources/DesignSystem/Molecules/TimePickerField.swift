import SwiftUI

struct TimePickerField: View {
    let label: String
    @Binding var selection: Date

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText(label, style: .labelMedium, color: ColorTokens.textSecondary)
            DatePicker(
                "",
                selection: $selection,
                displayedComponents: .hourAndMinute
            )
            #if os(iOS)
            .datePickerStyle(.wheel)
            #endif
            .labelsHidden()
            .tint(ColorTokens.primary)
        }
    }
}

#Preview {
    @Previewable @State var time = Date()
    TimePickerField(label: "Alarm Time", selection: $time)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
