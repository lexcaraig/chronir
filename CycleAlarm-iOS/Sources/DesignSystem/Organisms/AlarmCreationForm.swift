import SwiftUI

struct AlarmCreationForm: View {
    @Binding var title: String
    @Binding var cycleType: CycleType
    @Binding var scheduledTime: Date
    @Binding var isPersistent: Bool
    @Binding var note: String

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $title)

            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                CycleText("Cycle Type", font: TypographyTokens.labelMedium, color: ColorTokens.textSecondary)
                Picker("Cycle Type", selection: $cycleType) {
                    ForEach(CycleType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            TimePickerField(label: "Time", selection: $scheduledTime)

            CycleToggle(label: "Persistent (requires dismissal)", isOn: $isPersistent)

            LabeledTextField(label: "Note (optional)", placeholder: "Add a note...", text: $note)
        }
        .padding(SpacingTokens.lg)
    }
}

#Preview {
    @Previewable @State var title = ""
    @Previewable @State var cycleType = CycleType.weekly
    @Previewable @State var time = Date()
    @Previewable @State var isPersistent = false
    @Previewable @State var note = ""

    ScrollView {
        AlarmCreationForm(
            title: $title,
            cycleType: $cycleType,
            scheduledTime: $time,
            isPersistent: $isPersistent,
            note: $note
        )
    }
    .background(ColorTokens.backgroundPrimary)
}
