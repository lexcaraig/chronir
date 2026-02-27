import SwiftUI

struct AlarmCreationForm: View {
    @Binding var title: String
    @Binding var cycleType: CycleType
    @Binding var repeatInterval: Int
    @Binding var timesOfDay: [TimeOfDay]
    @Binding var isPersistent: Bool
    @Binding var note: String
    @Binding var selectedDays: Set<Int>
    @Binding var daysOfMonth: Set<Int>
    @Binding var annualMonth: Int
    @Binding var annualDay: Int
    @Binding var annualYear: Int
    @Binding var startMonth: Int
    @Binding var startYear: Int
    @Binding var category: AlarmCategory?
    @Binding var preAlarmOffsets: Set<PreAlarmOffset>
    @Binding var oneTimeDate: Date
    @Binding var soundName: String
    var isPlusTier: Bool = false
    var titleError: String?
    @State private var showPaywallForSound = false
    @State private var showSoundPicker = false
    @State private var savedIntervals: [CycleType: Int] = [:]

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            LabeledTextField(
                label: "Alarm Name",
                placeholder: "Enter a name...",
                text: $title,
                error: titleError,
                maxLength: AlarmValidator.titleMaxLength,
                softWarningLength: 32
            )

            IntervalPicker(
                selection: $cycleType,
                options: [.oneTime, .weekly, .monthlyDate, .annual]
            )

            if cycleType == .oneTime {
                oneTimeDatePicker
            } else if cycleType == .weekly {
                weeklyDayPicker
            } else if cycleType == .monthlyDate {
                monthlyDayPicker
                if daysOfMonth.contains(where: { $0 > 28 }) {
                    HStack(spacing: SpacingTokens.xs) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(ColorTokens.textSecondary)
                        ChronirText(
                            AlarmValidator.ValidationWarning.monthlyDay31.displayMessage,
                            style: .labelSmall,
                            color: ColorTokens.textSecondary
                        )
                    }
                }
            } else if cycleType == .annual {
                annualDatePicker
            }

            if cycleType != .oneTime {
                repeatIntervalPicker
            }

            if repeatInterval > 1 && (cycleType == .monthlyDate || cycleType == .monthlyRelative) {
                monthlyStartPicker
            }

            ChronirCategoryPicker(selection: $category)

            TimesOfDayPicker(times: $timesOfDay)

            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                ChronirToggle(label: "Require Dismissal", isOn: $isPersistent)
                ChronirText(
                    "Alarm will repeat after snooze until manually dismissed. Lock screen alerts are managed by iOS and may auto-silence.",
                    style: .labelSmall,
                    color: ColorTokens.textSecondary
                )
            }

            preAlarmSection

            soundSection

            if isPlusTier {
                LabeledTextField(
                    label: "Note (optional)",
                    placeholder: "Add a note...",
                    text: $note,
                    maxLength: AlarmValidator.noteMaxLength
                )
            } else if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    ChronirText("Note", style: .labelMedium, color: ColorTokens.textSecondary)
                    ChronirText(note, style: .bodyMedium)
                }
            }
        }
        .padding(SpacingTokens.lg)
        .onChange(of: cycleType) { oldValue, newValue in
            savedIntervals[oldValue] = repeatInterval
            repeatInterval = savedIntervals[newValue] ?? 1
        }
        .onChange(of: annualMonth) {
            annualDay = min(annualDay, daysInSelectedMonth)
        }
        .onChange(of: annualYear) {
            annualDay = min(annualDay, daysInSelectedMonth)
        }
    }

    private var oneTimeDatePicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Date", style: .labelMedium, color: ColorTokens.textSecondary)
            DatePicker(
                "Fire Date",
                selection: $oneTimeDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .fixedSize()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                            .chronirFont(.labelSmall)
                            .foregroundStyle(selectedDays.contains(day) ? .white : ColorTokens.textSecondary)
                            .frame(width: 36, height: 36)
                            .chronirGlassSelectableCircle(isSelected: selectedDays.contains(day))
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
                            .chronirFont(.labelSmall)
                            .foregroundStyle(daysOfMonth.contains(day) ? .white : ColorTokens.textSecondary)
                            .frame(width: 36, height: 36)
                            .chronirGlassSelectableCircle(isSelected: daysOfMonth.contains(day))
                    }
                }
            }
        }
    }

    private var annualDatePicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("First Occurrence", style: .labelMedium, color: ColorTokens.textSecondary)
            HStack(spacing: SpacingTokens.sm) {
                Picker("Month", selection: $annualMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Picker("Day", selection: $annualDay) {
                    ForEach(1...daysInSelectedMonth, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Picker("Year", selection: $annualYear) {
                    ForEach(currentYear...currentYear + 30, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Spacer()
            }
        }
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var daysInSelectedMonth: Int {
        let cal = Calendar.current
        var components = DateComponents()
        components.month = annualMonth
        components.year = annualYear
        guard let date = cal.date(from: components),
              let range = cal.range(of: .day, in: .month, for: date) else {
            return 31
        }
        return range.count
    }

    private var monthlyStartPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("First Occurrence", style: .labelMedium, color: ColorTokens.textSecondary)
            HStack(spacing: SpacingTokens.sm) {
                Picker("Month", selection: $startMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Picker("Year", selection: $startYear) {
                    ForEach(currentYear...currentYear + 10, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Spacer()
            }
        }
    }

    @State private var showPaywallFromPreAlarm = false

    private var preAlarmSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Pre-Alarm Warnings", style: .labelMedium, color: ColorTokens.textSecondary)
            HStack(spacing: SpacingTokens.sm) {
                ForEach(PreAlarmOffset.allCases) { offset in
                    let isSelected = preAlarmOffsets.contains(offset)
                    let isLocked = offset.requiresPlus && !isPlusTier
                    Button {
                        if isLocked {
                            showPaywallFromPreAlarm = true
                        } else if isSelected {
                            preAlarmOffsets.remove(offset)
                        } else {
                            preAlarmOffsets.insert(offset)
                        }
                    } label: {
                        HStack(spacing: SpacingTokens.xxs) {
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                            }
                            Text(offset.displayName)
                                .chronirFont(.labelLarge)
                        }
                        .foregroundStyle(isSelected ? .white : (isLocked ? ColorTokens.textDisabled : ColorTokens.textSecondary))
                        .padding(.horizontal, SpacingTokens.md)
                        .padding(.vertical, SpacingTokens.sm)
                        .background(isSelected ? ColorTokens.primary : ColorTokens.backgroundTertiary)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywallFromPreAlarm) {
            PaywallView()
        }
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Sound", style: .labelMedium, color: ColorTokens.textSecondary)
            Button {
                showSoundPicker = true
            } label: {
                HStack {
                    let displayName = AlarmSoundService.allSounds
                        .first { $0.name == soundName }?.displayName ?? "Default"
                    ChronirText(displayName, style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textTertiary)
                }
                .padding(SpacingTokens.md)
                .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: RadiusTokens.md))
            }
        }
        .sheet(isPresented: $showSoundPicker) {
            NavigationStack {
                SoundPicker(
                    selectedSound: $soundName,
                    isPlusTier: isPlusTier,
                    showPaywall: { showPaywallForSound = true }
                )
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showSoundPicker = false }
                            .foregroundStyle(ColorTokens.primary)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showPaywallForSound) {
            PaywallView()
        }
    }

    private var repeatIntervalPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Repeat Every", style: .labelMedium, color: ColorTokens.textSecondary)
            HStack(spacing: SpacingTokens.sm) {
                Stepper(value: $repeatInterval, in: 1...52) {
                    ChronirText(
                        "\(repeatInterval) \(intervalUnitLabel)",
                        style: .bodyLarge
                    )
                }
            }
        }
    }

    private var intervalUnitLabel: String {
        switch cycleType {
        case .weekly:
            return repeatInterval == 1 ? "week" : "weeks"
        case .monthlyDate, .monthlyRelative:
            return repeatInterval == 1 ? "month" : "months"
        case .annual:
            return repeatInterval == 1 ? "year" : "years"
        case .customDays:
            return repeatInterval == 1 ? "day" : "days"
        case .oneTime:
            return ""
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
    @Previewable @State var repeatInterval = 1
    @Previewable @State var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    @Previewable @State var isPersistent = false
    @Previewable @State var note = ""
    @Previewable @State var selectedDays: Set<Int> = [2]
    @Previewable @State var daysOfMonth: Set<Int> = [1]
    @Previewable @State var annualMonth = Calendar.current.component(.month, from: Date())
    @Previewable @State var annualDay = Calendar.current.component(.day, from: Date())
    @Previewable @State var annualYear = Calendar.current.component(.year, from: Date())
    @Previewable @State var startMonth = Calendar.current.component(.month, from: Date())
    @Previewable @State var startYear = Calendar.current.component(.year, from: Date())
    @Previewable @State var category: AlarmCategory?
    @Previewable @State var preAlarmOffsets: Set<PreAlarmOffset> = []
    @Previewable @State var oneTimeDate = Date()
    @Previewable @State var soundName = "alarm"

    ScrollView {
        AlarmCreationForm(
            title: $title,
            cycleType: $cycleType,
            repeatInterval: $repeatInterval,
            timesOfDay: $timesOfDay,
            isPersistent: $isPersistent,
            note: $note,
            selectedDays: $selectedDays,
            daysOfMonth: $daysOfMonth,
            annualMonth: $annualMonth,
            annualDay: $annualDay,
            annualYear: $annualYear,
            startMonth: $startMonth,
            startYear: $startYear,
            category: $category,
            preAlarmOffsets: $preAlarmOffsets,
            oneTimeDate: $oneTimeDate,
            soundName: $soundName,
            isPlusTier: true
        )
    }
    .background(ColorTokens.backgroundPrimary)
}
