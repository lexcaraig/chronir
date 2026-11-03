import SwiftUI
import TipKit

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
    @Binding var followUpInterval: FollowUpInterval
    var isPlusTier: Bool = false
    var titleError: String?
    @State private var showPaywallForNote = false
    @State private var showPaywallForSound = false
    @State private var showSoundPicker = false
    @State private var savedIntervals: [CycleType: Int] = [:]

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            FormSection("Name & Schedule") {
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
                        HStack(alignment: .firstTextBaseline, spacing: SpacingTokens.xs) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(ColorTokens.textSecondary)
                                .accessibilityHidden(true)
                            ChronirText(
                                AlarmValidator.ValidationWarning.monthlyDay31.displayMessage,
                                style: .labelSmall,
                                color: ColorTokens.textSecondary
                            )
                        }
                    }
                } else if cycleType == .annual {
                    FirstOccurrencePicker(
                        month: $annualMonth,
                        day: $annualDay,
                        year: $annualYear,
                        daysInMonth: daysInSelectedMonth,
                        yearsAhead: 30
                    )
                }

                if cycleType != .oneTime {
                    repeatIntervalPicker
                }

                if repeatInterval > 1 && (cycleType == .monthlyDate || cycleType == .monthlyRelative) {
                    FirstOccurrencePicker(month: $startMonth, year: $startYear, yearsAhead: 10)
                }
            }

            FormSection("Time") {
                TimesOfDayPicker(times: $timesOfDay)
            }

            FormSection("Alerts") {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    ChronirToggle(label: "Require Dismissal", isOn: $isPersistent)
                    ChronirText(
                        "Alarm will repeat after snooze until manually dismissed. "
                            + "Lock screen alerts are managed by iOS and may auto-silence.",
                        style: .labelSmall,
                        color: ColorTokens.textSecondary
                    )
                }

                if isPersistent && isPlusTier {
                    VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                        ChronirText("Follow-Up Interval", style: .labelMedium, color: ColorTokens.textSecondary)
                            .accessibilityHidden(true)
                        Picker("Follow-Up Interval", selection: $followUpInterval) {
                            ForEach(FollowUpInterval.allCases) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .pickerStyle(.segmented)
                        ChronirText(
                            "How often to ask \"Did you complete it?\" after stopping.",
                            style: .labelSmall,
                            color: ColorTokens.textSecondary
                        )
                    }
                }

                preAlarmSection

                soundSection
            }

            FormSection("Details") {
                ChronirCategoryPicker(selection: $category)

                noteSection
            }
        }
        .padding(SpacingTokens.md)
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

    @ViewBuilder
    private var noteSection: some View {
        if isPlusTier {
            LabeledTextField(
                label: "Note (optional)",
                placeholder: "Add a note...",
                text: $note,
                maxLength: AlarmValidator.noteMaxLength
            )
        } else {
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                HStack(spacing: SpacingTokens.xxs) {
                    ChronirText("Note", style: .labelMedium, color: ColorTokens.textSecondary)
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                .accessibilityHidden(true)
                let noteIsEmpty = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Button {
                    showPaywallForNote = true
                } label: {
                    HStack {
                        ChronirText(
                            noteIsEmpty ? "Add a note..." : note,
                            style: .bodyMedium,
                            color: noteIsEmpty ? ColorTokens.textSecondary : ColorTokens.textPrimary
                        )
                        Spacer()
                    }
                    .padding(SpacingTokens.md)
                    .frame(minHeight: SpacingTokens.touchMinTarget)
                    .background(ColorTokens.backgroundPrimary, in: .rect(cornerRadius: RadiusTokens.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(noteIsEmpty ? "Note, requires Plus" : "Note, \(note), requires Plus")
                .accessibilityHint("Opens the upgrade screen")
            }
            .fullScreenCover(isPresented: $showPaywallForNote) {
                PaywallView(highlight: .notes)
            }
        }
    }

    private var oneTimeDatePicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Date", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityHidden(true)
            DatePicker(
                "Date",
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
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: SpacingTokens.xxs) {
                ForEach(weekdays, id: \.weekday) { day in
                    ChronirChip(
                        day.initial,
                        isSelected: selectedDays.contains(day.weekday),
                        shape: .circle,
                        accessibilityLabel: day.name
                    ) {
                        toggle(day.weekday, in: &selectedDays)
                    }
                }
            }
        }
    }

    private var monthlyDayPicker: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Days of Month", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityAddTraits(.isHeader)
            let columns = Array(repeating: GridItem(.flexible(), spacing: SpacingTokens.xxs), count: 7)
            LazyVGrid(columns: columns, spacing: SpacingTokens.xxs) {
                ForEach(1...31, id: \.self) { day in
                    ChronirChip(
                        "\(day)",
                        isSelected: daysOfMonth.contains(day),
                        shape: .circle,
                        accessibilityLabel: "Day \(day)"
                    ) {
                        toggle(day, in: &daysOfMonth)
                    }
                }
            }
        }
    }

    /// Adds or removes `value`, keeping at least one selection.
    private func toggle(_ value: Int, in set: inout Set<Int>) {
        if set.contains(value) {
            if set.count > 1 { set.remove(value) }
        } else {
            set.insert(value)
        }
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

    @State private var showPaywallFromPreAlarm = false

    private var preAlarmSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Pre-Alarm Warnings", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityAddTraits(.isHeader)
                .popoverTip(PreAlarmTip())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    ForEach(PreAlarmOffset.allCases) { offset in
                        let isSelected = preAlarmOffsets.contains(offset)
                        let isLocked = offset.requiresPlus && !isPlusTier
                        ChronirChip(
                            offset.displayName,
                            isSelected: isSelected,
                            isLocked: isLocked,
                            accessibilityLabel: "\(offset.displayName) before"
                        ) {
                            if isLocked {
                                showPaywallFromPreAlarm = true
                            } else if isSelected {
                                preAlarmOffsets.remove(offset)
                            } else {
                                preAlarmOffsets.insert(offset)
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywallFromPreAlarm) {
            PaywallView(highlight: .preAlarm)
        }
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Sound", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityHidden(true)
            let displayName = AlarmSoundService.allSounds
                .first { $0.name == soundName }?.displayName ?? "Default"
            Button {
                showSoundPicker = true
            } label: {
                HStack {
                    ChronirText(displayName, style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(SpacingTokens.md)
                .frame(minHeight: SpacingTokens.touchMinTarget)
                .background(ColorTokens.backgroundPrimary, in: .rect(cornerRadius: RadiusTokens.md))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sound, \(displayName)")
            .accessibilityHint("Choose the alarm sound")
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
            PaywallView(highlight: .sounds)
        }
    }

    private var repeatIntervalPicker: some View {
        Stepper(value: $repeatInterval, in: 1...52) {
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                ChronirText("Repeat Every", style: .labelMedium, color: ColorTokens.textSecondary)
                ChronirText(
                    "\(repeatInterval) \(intervalUnitLabel)",
                    style: .bodyLarge
                )
            }
            .accessibilityElement(children: .combine)
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

    /// Monday-first week as Calendar weekday numbers (1 = Sunday … 7 = Saturday) — what `selectedDays` stores.
    private var weekdays: [Weekday] {
        [2, 3, 4, 5, 6, 7, 1].map(Weekday.init)
    }
}

/// One weekday chip: the very short symbol on screen, the full localized name for VoiceOver.
private struct Weekday {
    let weekday: Int
    var initial: String { Calendar.current.veryShortStandaloneWeekdaySymbols[weekday - 1] }
    var name: String { Calendar.current.standaloneWeekdaySymbols[weekday - 1] }
}

/// Month / (day) / year menus for "First Occurrence". Stacks vertically when the menus no longer fit
/// one row (large text sizes).
private struct FirstOccurrencePicker: View {
    @Binding var month: Int
    var day: Binding<Int>?
    @Binding var year: Int
    var daysInMonth = 31
    let yearsAhead: Int

    init(month: Binding<Int>, day: Binding<Int>? = nil, year: Binding<Int>, daysInMonth: Int = 31, yearsAhead: Int) {
        self._month = month
        self.day = day
        self._year = year
        self.daysInMonth = daysInMonth
        self.yearsAhead = yearsAhead
    }

    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("First Occurrence", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityAddTraits(.isHeader)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: SpacingTokens.sm) {
                    menus
                    Spacer()
                }
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    menus
                }
            }
        }
    }

    @ViewBuilder
    private var menus: some View {
        Picker("Month", selection: $month) {
            ForEach(1...12, id: \.self) { month in
                Text(Calendar.current.monthSymbols[month - 1]).tag(month)
            }
        }
        .pickerStyle(.menu)
        .fixedSize()

        if let day {
            Picker("Day", selection: day) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.menu)
            .fixedSize()
        }

        Picker("Year", selection: $year) {
            ForEach(currentYear...currentYear + yearsAhead, id: \.self) { year in
                Text(String(year)).tag(year)
            }
        }
        .pickerStyle(.menu)
        .fixedSize()
    }
}

/// Inset-grouped section: a header above a `surfaceCard` panel, so the long form reads as
/// Name & Schedule / Time / Alerts / Details instead of one undifferentiated column.
private struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText(title, style: .titleSmall, color: ColorTokens.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, SpacingTokens.xxs)
            VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                content()
            }
            .padding(SpacingTokens.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .chronirGlassCard()
        }
    }
}
