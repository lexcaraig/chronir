import SwiftUI

struct ComponentCatalog: View {
    var body: some View {
        List {
            Section("Atoms") {
                NavigationLink("ChronirText") { CatalogTextView() }
                NavigationLink("ChronirButton") { CatalogButtonView() }
                NavigationLink("ChronirBadge") { CatalogBadgeView() }
                NavigationLink("ChronirIcon") { CatalogIconView() }
                NavigationLink("ChronirToggle") { CatalogToggleView() }
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section("Molecules") {
                NavigationLink("AlarmTimeDisplay") { CatalogAlarmTimeDisplayView() }
                NavigationLink("AlarmToggleRow") { CatalogAlarmToggleRowView() }
                NavigationLink("IntervalPicker") { CatalogIntervalPickerView() }
                NavigationLink("SnoozeOptionBar") { CatalogSnoozeBarView() }
                NavigationLink("LabeledTextField") { CatalogLabeledTextFieldView() }
                NavigationLink("TimePickerField") { CatalogTimePickerFieldView() }
                NavigationLink("TimesOfDayPicker") { CatalogTimesOfDayPickerView() }
                NavigationLink("ChronirCategoryPicker") { CatalogCategoryPickerView() }
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section("Organisms") {
                NavigationLink("AlarmCard") { CatalogAlarmCardView() }
                NavigationLink("CategoryGroupCard") { CatalogCategoryGroupCardView() }
                NavigationLink("AlarmListSection") { CatalogAlarmListSectionView() }
                NavigationLink("EmptyStateView") { CatalogEmptyStateView() }
                NavigationLink("AlarmFiringOverlay") { CatalogAlarmFiringOverlayView() }
                NavigationLink("AlarmCreationForm") { CatalogAlarmCreationFormView() }
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section("Templates") {
                NavigationLink("SingleColumnTemplate") { CatalogSingleColumnView() }
                NavigationLink("ModalSheetTemplate") { CatalogModalSheetView() }
                NavigationLink("FullScreenAlarmTemplate") { CatalogFullScreenView() }
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Design System")
    }
}

// MARK: - Atom Catalog Views

private struct CatalogTextView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingTokens.md) {
                ChronirText("12:00", style: .displayAlarm)
                ChronirText("3:45 PM", style: .headlineTime)
                ChronirText("Screen Title", style: .headlineTitle)
                ChronirText("Primary body text", style: .bodyPrimary)
                ChronirText("Secondary metadata", style: .bodySecondary, color: ColorTokens.textSecondary)
                ChronirText("Countdown", style: .captionCountdown)
                ChronirText("Badge", style: .captionBadge)
            }
            .padding()
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirText")
    }
}

private struct CatalogButtonView: View {
    var body: some View {
        AdaptiveGlassContainer {
            VStack(spacing: SpacingTokens.md) {
                ChronirButton("Primary Action") {}
                ChronirButton("Secondary", style: .secondary) {}
                ChronirButton("Destructive", style: .destructive) {}
                ChronirButton("Ghost Action", style: .ghost) {}
            }
            .padding()
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirButton")
    }
}

private struct CatalogBadgeView: View {
    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            HStack(spacing: SpacingTokens.sm) {
                ChronirBadge(cycleType: .weekly)
                ChronirBadge(cycleType: .monthlyDate)
                ChronirBadge(cycleType: .annual)
                ChronirBadge(cycleType: .customDays)
            }
            HStack(spacing: SpacingTokens.sm) {
                ChronirBadge("Active", color: ColorTokens.badgeSuccess)
                ChronirBadge("Persistent", color: ColorTokens.badgeWarning)
                ChronirBadge("Missed", color: ColorTokens.badgeError)
            }
        }
        .padding()
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirBadge")
    }
}

private struct CatalogIconView: View {
    var body: some View {
        HStack(spacing: SpacingTokens.lg) {
            ChronirIcon(systemName: "alarm.fill", size: .small, color: ColorTokens.textSecondary)
            ChronirIcon(systemName: "alarm.fill", size: .medium, color: ColorTokens.primary)
            ChronirIcon(systemName: "alarm.fill", size: .large, color: ColorTokens.warning)
        }
        .padding()
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirIcon")
    }
}

private struct CatalogToggleView: View {
    @State private var isOn = true
    @State private var isOff = false

    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            ChronirToggle(label: "Enabled Toggle", isOn: $isOn)
            ChronirToggle(label: "Disabled Toggle", isOn: $isOff)
        }
        .padding()
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirToggle")
    }
}

// MARK: - Molecule Catalog Views

private struct CatalogAlarmTimeDisplayView: View {
    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            AlarmTimeDisplay(time: Date(), countdownText: "Alarm in 6h 32m")
            AlarmTimeDisplay(time: Date())
        }
        .padding()
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("AlarmTimeDisplay")
    }
}

private struct CatalogAlarmToggleRowView: View {
    @State private var isEnabled = true

    var body: some View {
        VStack {
            AlarmToggleRow(
                title: "Morning Workout",
                subtitle: "Every Monday at 6:30 AM",
                cycleType: .weekly,
                isEnabled: $isEnabled
            )
        }
        .background(ColorTokens.surfaceCard)
        .padding()
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("AlarmToggleRow")
    }
}

private struct CatalogIntervalPickerView: View {
    @State private var selected: CycleType = .weekly

    var body: some View {
        AdaptiveGlassContainer {
            IntervalPicker(selection: $selected)
                .padding()
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("IntervalPicker")
    }
}

private struct CatalogSnoozeBarView: View {
    var body: some View {
        SnoozeOptionBar(onSnooze: { _ in })
            .padding()
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("SnoozeOptionBar")
    }
}

private struct CatalogLabeledTextFieldView: View {
    @State private var text = ""

    var body: some View {
        LabeledTextField(label: "Alarm Name", placeholder: "Enter name...", text: $text)
            .padding()
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("LabeledTextField")
    }
}

private struct CatalogTimePickerFieldView: View {
    @State private var time = Date()

    var body: some View {
        TimePickerField(label: "Time", selection: $time)
            .padding()
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("TimePickerField")
    }
}

private struct CatalogTimesOfDayPickerView: View {
    @State private var times: [TimeOfDay] = [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 17, minute: 0)
    ]

    var body: some View {
        TimesOfDayPicker(times: $times)
            .padding()
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("TimesOfDayPicker")
    }
}

// MARK: - Organism Catalog Views

private struct CatalogAlarmCardView: View {
    @State private var enabled1 = true
    @State private var enabled2 = false
    @State private var enabled3 = true
    @State private var enabled4 = true

    var body: some View {
        ScrollView {
            AdaptiveGlassContainer {
                VStack(spacing: SpacingTokens.md) {
                    AlarmCard(
                        alarm: Alarm(title: "Active Card", cycleType: .weekly, persistenceLevel: .full),
                        visualState: .active,
                        isEnabled: $enabled1
                    )
                    AlarmCard(
                        alarm: Alarm(
                            title: "Inactive Card", cycleType: .monthlyDate,
                            schedule: .monthlyDate(daysOfMonth: [1], interval: 1)
                        ),
                        visualState: .inactive,
                        isEnabled: $enabled2
                    )
                    AlarmCard(
                        alarm: Alarm(title: "Snoozed Card", cycleType: .weekly),
                        visualState: .snoozed,
                        isEnabled: $enabled3
                    )
                    AlarmCard(
                        alarm: Alarm(
                            title: "Overdue Card", cycleType: .annual,
                            schedule: .annual(month: 1, dayOfMonth: 1, interval: 1),
                            nextFireDate: Date().addingTimeInterval(-3600)
                        ),
                        visualState: .overdue,
                        isEnabled: $enabled4
                    )
                }
                .padding()
            }
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("AlarmCard")
    }
}

private struct CatalogCategoryGroupCardView: View {
    var body: some View {
        ScrollView {
            AdaptiveGlassContainer {
                VStack(spacing: SpacingTokens.md) {
                    CategoryGroupCard(
                        category: .finance,
                        alarms: [
                            Alarm(title: "Pay Rent", cycleType: .monthlyDate, category: "finance"),
                            Alarm(title: "Credit Card Bill", cycleType: .monthlyDate, category: "finance")
                        ],
                        enabledStates: [:]
                    )
                    CategoryGroupCard(
                        category: .health,
                        alarms: [
                            Alarm(title: "Annual Checkup", cycleType: .annual, category: "health"),
                            Alarm(title: "Dentist", cycleType: .annual, category: "health"),
                            Alarm(title: "Eye Exam", cycleType: .annual, category: "health"),
                            Alarm(title: "Flu Shot", cycleType: .annual, category: "health")
                        ],
                        enabledStates: [:]
                    )
                }
                .padding()
            }
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("CategoryGroupCard")
    }
}

private struct CatalogAlarmListSectionView: View {
    @State private var enabledStates: [UUID: Bool] = [:]

    var body: some View {
        ScrollView {
            AlarmListSection(
                title: "Upcoming",
                alarms: [
                    Alarm(title: "Workout", cycleType: .weekly, nextFireDate: Date().addingTimeInterval(3600)),
                    Alarm(
                        title: "Pay Rent", cycleType: .monthlyDate,
                        schedule: .monthlyDate(daysOfMonth: [1], interval: 1),
                        nextFireDate: Date().addingTimeInterval(-3600)
                    )
                ],
                enabledStates: $enabledStates
            )
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("AlarmListSection")
    }
}

private struct CatalogEmptyStateView: View {
    var body: some View {
        EmptyStateView(onCreateAlarm: {})
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("EmptyStateView")
    }
}

private struct CatalogAlarmFiringOverlayView: View {
    var body: some View {
        AlarmFiringOverlay(
            alarm: Alarm(title: "Morning Workout", cycleType: .weekly, persistenceLevel: .full),
            snoozeCount: 1,
            onDismiss: {},
            onSnooze: { _ in }
        )
        .navigationTitle("AlarmFiringOverlay")
    }
}

private struct CatalogAlarmCreationFormView: View {
    @State private var title = ""
    @State private var cycleType = CycleType.weekly
    @State private var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    @State private var repeatInterval = 1
    @State private var isPersistent = false
    @State private var note = ""
    @State private var selectedDays: Set<Int> = [2]
    @State private var daysOfMonth: Set<Int> = [1]
    @State private var annualMonth = Calendar.current.component(.month, from: Date())
    @State private var annualDay = Calendar.current.component(.day, from: Date())
    @State private var annualYear = Calendar.current.component(.year, from: Date())
    @State private var startMonth = Calendar.current.component(.month, from: Date())
    @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var category: AlarmCategory?

    var body: some View {
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
                preAlarmOffsets: .constant([]),
                oneTimeDate: .constant(Date()),
                soundName: .constant("alarm"),
                titleError: nil
            )
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("AlarmCreationForm")
    }
}

private struct CatalogCategoryPickerView: View {
    @State private var selection: AlarmCategory? = .home

    var body: some View {
        AdaptiveGlassContainer {
            ChronirCategoryPicker(selection: $selection)
                .padding()
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("ChronirCategoryPicker")
    }
}

// MARK: - Template Catalog Views

private struct CatalogSingleColumnView: View {
    var body: some View {
        SingleColumnTemplate(title: "Sample") {
            ForEach(0..<5) { index in
                ChronirText("Item \(index)", style: .bodyPrimary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ColorTokens.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
            }
        }
        .navigationTitle("SingleColumnTemplate")
    }
}

private struct CatalogModalSheetView: View {
    @State private var showSheet = false

    var body: some View {
        VStack {
            ChronirButton("Show Modal Sheet") {
                showSheet = true
            }
            .padding()
        }
        .background(ColorTokens.backgroundPrimary)
        .sheet(isPresented: $showSheet) {
            ModalSheetTemplate(
                title: "Sample",
                onDismiss: { showSheet = false },
                onSave: { showSheet = false },
                content: {
                    ChronirText("Modal content", style: .bodyPrimary)
                        .padding()
                }
            )
        }
        .navigationTitle("ModalSheetTemplate")
    }
}

private struct CatalogFullScreenView: View {
    var body: some View {
        FullScreenAlarmTemplate {
            VStack {
                ChronirText("ALARM FIRING", style: .displayLarge)
                ChronirText("12:00 PM", style: .displayAlarm)
            }
        }
        .navigationTitle("FullScreenAlarmTemplate")
    }
}

#Preview {
    NavigationStack {
        ComponentCatalog()
    }
}
