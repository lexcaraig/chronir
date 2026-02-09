import SwiftUI

struct AlarmCreationForm: View {
    @Binding var title: String
    @Binding var cycleType: CycleType
    @Binding var scheduledTime: Date
    @Binding var isPersistent: Bool
    @Binding var note: String
    @Binding var selectedDays: Set<Int>
    @Binding var daysOfMonth: Set<Int>
    @Binding var category: AlarmCategory?

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $title)

            IntervalPicker(selection: $cycleType)

            if cycleType == .weekly {
                weeklyDayPicker
            } else if cycleType == .monthlyDate {
                monthlyDayPicker
            }

            ChronirCategoryPicker(selection: $category)

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
                            .glassEffect(
                                selectedDays.contains(day)
                                    ? GlassTokens.element.tint(ColorTokens.primary).interactive()
                                    : GlassTokens.element,
                                in: .circle
                            )
                    }
                }
            }
        }
    }

    private var monthlyDayPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Days of Month", style: .labelMedium, color: ColorTokens.textSecondary)
            let columns = Array(repeating: GridItem(.flexible(), spacing: SpacingTokens.xs), count: 7)
            LazyVGrid(columns: columns, spacing: SpacingTokens.xs) {
                ForEach(1...31, id: \.self) { day in
                    Button {
                        if daysOfMonth.contains(day) {
                            if daysOfMonth.count > 1 { daysOfMonth.remove(day) }
                        } else {
                            daysOfMonth.insert(day)
                        }
                    } label: {
                        Text("\(day)")
                            .font(TypographyTokens.labelSmall)
                            .foregroundStyle(daysOfMonth.contains(day) ? .white : ColorTokens.textSecondary)
                            .frame(width: 36, height: 36)
                            .glassEffect(
                                daysOfMonth.contains(day)
                                    ? GlassTokens.element.tint(ColorTokens.primary).interactive()
                                    : GlassTokens.element,
                                in: .circle
                            )
                    }
                }
            }
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
    @Previewable @State var daysOfMonth: Set<Int> = [1]
    @Previewable @State var category: AlarmCategory?

    ScrollView {
        AlarmCreationForm(
            title: $title,
            cycleType: $cycleType,
            scheduledTime: $time,
            isPersistent: $isPersistent,
            note: $note,
            selectedDays: $selectedDays,
            daysOfMonth: $daysOfMonth,
            category: $category
        )
    }
    .background(ColorTokens.backgroundPrimary)
}
