import SwiftUI
import SwiftData

struct AlarmCreationView: View {
    let modelContext: ModelContext
    @Query(sort: \Alarm.nextFireDate) private var existingAlarms: [Alarm]
    @State private var title = ""
    @State private var cycleType: CycleType = .weekly
    @State private var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    @State private var isPersistent = false
    @State private var note = ""
    @State private var selectedDays: Set<Int> = [2]
    @State private var daysOfMonth: Set<Int> = [1]
    @State private var category: AlarmCategory?
    @State private var saveError: String?
    @State private var conflictWarning: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ModalSheetTemplate(
            title: "New Alarm",
            onDismiss: { dismiss() },
            onSave: { saveAndDismiss() },
            content: {
                AlarmCreationForm(
                    title: $title,
                    cycleType: $cycleType,
                    timesOfDay: $timesOfDay,
                    isPersistent: $isPersistent,
                    note: $note,
                    selectedDays: $selectedDays,
                    daysOfMonth: $daysOfMonth,
                    category: $category
                )
                if let conflictWarning {
                    HStack(spacing: SpacingTokens.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(ColorTokens.warning)
                        ChronirText(conflictWarning, style: .bodySmall, color: ColorTokens.warning)
                    }
                    .padding(SpacingTokens.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ColorTokens.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
                    .padding(.horizontal, SpacingTokens.md)
                }
            }
        )
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
        .onChange(of: category) {
            conflictWarning = nil
        }
    }

    private func saveAndDismiss() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            saveError = "Please enter an alarm name."
            return
        }

        let calendar = Calendar.current

        let schedule: Schedule
        switch cycleType {
        case .weekly:
            schedule = .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: 1)
        case .monthlyDate:
            schedule = .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: 1)
        case .monthlyRelative:
            schedule = .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1)
        case .annual:
            let now = Date()
            schedule = .annual(
                month: calendar.component(.month, from: now),
                dayOfMonth: calendar.component(.day, from: now),
                interval: 1
            )
        case .customDays:
            schedule = .customDays(intervalDays: 7, startDate: Date())
        }

        let alarm = Alarm(
            title: trimmedTitle,
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            category: category?.rawValue,
            note: note.isEmpty ? nil : note
        )

        alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())

        // Check for same-day conflicts within the same category (non-blocking, show once)
        if conflictWarning == nil, let selectedCategory = category {
            let newFireDay = calendar.startOfDay(for: alarm.nextFireDate)
            let conflicts = existingAlarms.filter { existing in
                existing.isEnabled
                    && existing.alarmCategory == selectedCategory
                    && calendar.startOfDay(for: existing.nextFireDate) == newFireDay
            }
            if !conflicts.isEmpty {
                let names = conflicts.map(\.title).joined(separator: ", ")
                conflictWarning = "\(names) also fire\(conflicts.count == 1 ? "s" : "") on the same day."
                return
            }
        }

        modelContext.insert(alarm)

        do {
            try modelContext.save()
            // Schedule the notification
            Task {
                do {
                    _ = await PermissionManager.shared.requestAlarmPermission()
                    try await AlarmScheduler.shared.scheduleAlarm(alarm)
                } catch {
                    print("Failed to schedule notification: \(error)")
                }
            }
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Alarm.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    AlarmCreationView(modelContext: container.mainContext)
}
