import SwiftUI

struct AlarmCreationForm: View {
    @Binding var title: String
    @Binding var cycleType: CycleType
    @Binding var scheduledTime: Date
    @Binding var isPersistent: Bool
    @Binding var note: String
    @Binding var selectedDays: Set<Int>
    @Binding var dayOfMonth: Int

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $title)

            IntervalPicker(selection: $cycleType)

            if cycleType == .weekly {
                weeklyDayPicker
            } else if cycleType == .monthlyDate {
                monthlyDayPicker
            }

            TimePickerField(label: "Time", selection: $scheduledTime)

            ChronirToggle(label: "Persistent (requires dismissal)", isOn: $isPersistent)

            LabeledTextField(label: "Note (optional)", placeholder: "Add a note...", text: $note)
        }
        .padding(SpacingTokens.lg)
    }

    private var weeklyDayPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Days", style: .labelMedium, color: ColorTokens.textSecondary)
            HStack(spacing: SpacingTokens.xs) {
                ForEach(dayLabels, id: \.0) { day, label in
                    Button {
                        if selectedDays.contains(day) {
                            if selectedDays.count > 1 { selectedDays.remove(day) }
                        } else {
                            selectedDays.insert(day)
                        }
                    } label: {
                        Text(label)
                            .font(TypographyTokens.labelSmall)
                            .foregroundStyle(selectedDays.contains(day) ? .white : ColorTokens.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                selectedDays.contains(day)
                                    ? ColorTokens.primary : ColorTokens.backgroundTertiary
                            )
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private var monthlyDayPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Day of Month", style: .labelMedium, color: ColorTokens.textSecondary)
            Picker("Day", selection: $dayOfMonth) {
                ForEach(1...31, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            #if os(iOS)
            .pickerStyle(.wheel)
            #endif
            .frame(height: 100)
        }
    }

    // ISO weekday: 1=Mon, 7=Sun
    private var dayLabels: [(Int, String)] {
        [(2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S"), (1, "S")]
    }
}

#Preview {
    @Previewable @State var title = ""
    @Previewable @State var cycleType = CycleType.weekly
    @Previewable @State var time = Date()
    @Previewable @State var isPersistent = false
    @Previewable @State var note = ""
    @Previewable @State var selectedDays: Set<Int> = [2]
    @Previewable @State var dayOfMonth = 1

    ScrollView {
        AlarmCreationForm(
            title: $title,
            cycleType: $cycleType,
            scheduledTime: $time,
            isPersistent: $isPersistent,
            note: $note,
            selectedDays: $selectedDays,
            dayOfMonth: $dayOfMonth
        )
    }
    .background(ColorTokens.backgroundPrimary)
}
