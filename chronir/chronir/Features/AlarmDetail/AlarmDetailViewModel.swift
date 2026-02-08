import Foundation
import Observation
import SwiftData
#if canImport(UserNotifications)
import UserNotifications
#endif

@Observable
final class AlarmDetailViewModel {
    var alarm: Alarm?
    var title: String = ""
    var cycleType: CycleType = .weekly
    var scheduledTime: Date = Date()
    var isPersistent: Bool = false
    var note: String = ""
    var selectedDays: Set<Int> = [2]
    var dayOfMonth: Int = 1
    var isLoading: Bool = false
    var errorMessage: String?

    private let dateCalculator = DateCalculator()

    func loadAlarm(id: UUID, context: ModelContext) {
        isLoading = true
        defer { isLoading = false }

        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.id == id }
        )

        do {
            guard let alarm = try context.fetch(descriptor).first else {
                errorMessage = "Alarm not found"
                return
            }
            self.alarm = alarm
            self.title = alarm.title
            self.cycleType = alarm.cycleType
            self.isPersistent = alarm.persistenceLevel == .full
            self.note = alarm.note ?? ""

            let cal = Calendar.current
            self.scheduledTime = cal.date(
                from: DateComponents(hour: alarm.timeOfDayHour, minute: alarm.timeOfDayMinute)
            ) ?? Date()

            switch alarm.schedule {
            case .weekly(let daysOfWeek, _):
                self.selectedDays = Set(daysOfWeek)
            case .monthlyDate(let day, _):
                self.dayOfMonth = day
            default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateAlarm(context: ModelContext) {
        guard let alarm else { return }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: scheduledTime)
        let minute = calendar.component(.minute, from: scheduledTime)

        alarm.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        alarm.cycleType = cycleType
        alarm.timeOfDayHour = hour
        alarm.timeOfDayMinute = minute
        alarm.schedule = buildSchedule()
        alarm.persistenceLevel = isPersistent ? .full : .notificationOnly
        alarm.note = note.isEmpty ? nil : note
        alarm.updatedAt = Date()
        alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())

        do {
            try context.save()
            // Reschedule the notification
            let alarmToSchedule = alarm
            Task {
                do {
                    try await AlarmScheduler.shared.cancelAlarm(alarmToSchedule)
                    if alarmToSchedule.isEnabled {
                        try await AlarmScheduler.shared.scheduleAlarm(alarmToSchedule)
                    }
                } catch {
                    print("Failed to reschedule notification: \(error)")
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAlarm(context: ModelContext) {
        guard let alarm else { return }
        // Capture ID before deletion — accessing SwiftData object after delete crashes
        let alarmIDString = alarm.id.uuidString
        context.delete(alarm)
        do {
            try context.save()
            self.alarm = nil
            #if os(iOS)
            Task {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [alarmIDString])
                center.removeDeliveredNotifications(withIdentifiers: [alarmIDString])
            }
            #endif
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func buildSchedule() -> Schedule {
        switch cycleType {
        case .weekly:
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: 1)
        case .monthlyDate:
            return .monthlyDate(dayOfMonth: dayOfMonth, interval: 1)
        case .monthlyRelative:
            return .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: 1)
        case .annual:
            let cal = Calendar.current
            return .annual(
                month: cal.component(.month, from: scheduledTime),
                dayOfMonth: cal.component(.day, from: scheduledTime),
                interval: 1
            )
        case .customDays:
            return .customDays(intervalDays: 7, startDate: Date())
        }
    }
}
