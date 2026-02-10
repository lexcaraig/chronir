import Foundation
import Observation
import SwiftData
#if canImport(UIKit)
import UIKit
#endif
#if canImport(UserNotifications)
import UserNotifications
#endif

@Observable
final class AlarmDetailViewModel {
    var alarm: Alarm?
    var title: String = ""
    var cycleType: CycleType = .weekly
    var repeatInterval: Int = 1
    var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    var isPersistent: Bool = false
    var note: String = ""
    var selectedDays: Set<Int> = [2]
    var daysOfMonth: Set<Int> = [1]
    var annualMonth: Int = Calendar.current.component(.month, from: Date())
    var annualDay: Int = Calendar.current.component(.day, from: Date())
    var annualYear: Int = Calendar.current.component(.year, from: Date())
    var startMonth: Int = Calendar.current.component(.month, from: Date())
    var startYear: Int = Calendar.current.component(.year, from: Date())
    var category: AlarmCategory?
    var selectedImage: UIImage?
    var removePhoto = false
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
            self.category = alarm.alarmCategory
            self.timesOfDay = alarm.timesOfDay
            #if os(iOS)
            if alarm.photoFileName != nil {
                self.selectedImage = PhotoStorageService.loadPhoto(for: alarm.id)
            }
            #endif

            switch alarm.schedule {
            case .weekly(let daysOfWeek, let interval):
                self.selectedDays = Set(daysOfWeek)
                self.repeatInterval = interval
            case .monthlyDate(let days, let interval):
                self.daysOfMonth = Set(days)
                self.repeatInterval = interval
                if interval > 1 {
                    self.startMonth = Calendar.current.component(.month, from: alarm.nextFireDate)
                    self.startYear = Calendar.current.component(.year, from: alarm.nextFireDate)
                }
            case .monthlyRelative(_, _, let interval):
                self.repeatInterval = interval
                if interval > 1 {
                    self.startMonth = Calendar.current.component(.month, from: alarm.nextFireDate)
                    self.startYear = Calendar.current.component(.year, from: alarm.nextFireDate)
                }
            case .annual(let month, let dayOfMonth, let interval):
                self.annualMonth = month
                self.annualDay = dayOfMonth
                self.annualYear = Calendar.current.component(.year, from: alarm.nextFireDate)
                self.repeatInterval = interval
            case .customDays(let intervalDays, _):
                self.repeatInterval = intervalDays
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateAlarm(context: ModelContext) {
        guard let alarm else { return }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        alarm.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        alarm.cycleType = cycleType
        alarm.timesOfDay = timesOfDay
        alarm.schedule = buildSchedule()
        alarm.persistenceLevel = isPersistent ? .full : .notificationOnly
        alarm.note = note.isEmpty ? nil : note
        alarm.category = category?.rawValue
        alarm.updatedAt = Date()
        if cycleType == .annual {
            let cal = Calendar.current
            let firstTime = timesOfDay.sorted().first ?? TimeOfDay(hour: 8, minute: 0)
            let targetDate = cal.date(from: DateComponents(
                year: annualYear, month: annualMonth, day: annualDay,
                hour: firstTime.hour, minute: firstTime.minute
            )) ?? Date()
            alarm.nextFireDate = targetDate > Date()
                ? targetDate
                : dateCalculator.calculateNextFireDate(for: alarm, from: Date())
        } else if repeatInterval > 1 && (cycleType == .monthlyDate || cycleType == .monthlyRelative) {
            let cal = Calendar.current
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
            let firstDay = cycleType == .monthlyDate ? Array(daysOfMonth).min() ?? 1 : 1
            let targetDate = cal.date(from: DateComponents(
                year: startYear, month: startMonth, day: firstDay,
                hour: firstTime.hour, minute: firstTime.minute
            )) ?? Date()
            alarm.nextFireDate = targetDate > Date()
                ? targetDate
                : dateCalculator.calculateNextFireDate(for: alarm, from: Date())
        } else {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
        }

        #if os(iOS)
        if removePhoto {
            PhotoStorageService.deletePhoto(for: alarm.id)
            alarm.photoFileName = nil
        } else if let selectedImage {
            alarm.photoFileName = PhotoStorageService.savePhoto(selectedImage, for: alarm.id)
        }
        #endif

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
        // Clean up photo file
        PhotoStorageService.deletePhoto(for: alarm.id)
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
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: repeatInterval)
        case .monthlyDate:
            return .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: repeatInterval)
        case .monthlyRelative:
            return .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: repeatInterval)
        case .annual:
            return .annual(
                month: annualMonth,
                dayOfMonth: annualDay,
                interval: repeatInterval
            )
        case .customDays:
            return .customDays(intervalDays: repeatInterval, startDate: Date())
        }
    }
}
