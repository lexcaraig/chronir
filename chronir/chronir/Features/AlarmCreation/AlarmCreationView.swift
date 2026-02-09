import SwiftUI
import SwiftData

struct AlarmCreationView: View {
    let modelContext: ModelContext
    @State private var title = ""
    @State private var cycleType: CycleType = .weekly
    @State private var scheduledTime = Date()
    @State private var isPersistent = false
    @State private var note = ""
    @State private var selectedDays: Set<Int> = [2]
    @State private var dayOfMonth = 1
    @State private var saveError: String?
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
                    scheduledTime: $scheduledTime,
                    isPersistent: $isPersistent,
                    note: $note,
                    selectedDays: $selectedDays,
                    dayOfMonth: $dayOfMonth
                )
            }
        )
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    private func saveAndDismiss() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            saveError = "Please enter an alarm name."
            return
        }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: scheduledTime)
        let minute = calendar.component(.minute, from: scheduledTime)

        let schedule: Schedule
        switch cycleType {
        case .weekly:
            schedule = .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: 1)
        case .monthlyDate:
            schedule = .monthlyDate(dayOfMonth: dayOfMonth, interval: 1)
        case .monthlyRelative:
            schedule = .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1)
        case .annual:
            schedule = .annual(
                month: calendar.component(.month, from: scheduledTime),
                dayOfMonth: calendar.component(.day, from: scheduledTime),
                interval: 1
            )
        case .customDays:
            schedule = .customDays(intervalDays: 7, startDate: Date())
        }

        let alarm = Alarm(
            title: trimmedTitle,
            cycleType: cycleType,
            timeOfDayHour: hour,
            timeOfDayMinute: minute,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            note: note.isEmpty ? nil : note
        )

        alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())

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
