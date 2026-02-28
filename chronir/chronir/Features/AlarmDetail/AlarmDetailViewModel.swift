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
    var preAlarmOffsets: Set<PreAlarmOffset> = []
    var oneTimeDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var soundName: String = UserSettings.shared.selectedAlarmSound
    var followUpInterval: FollowUpInterval = .thirtyMinutes
    var selectedImage: UIImage?
    var removePhoto = false
    var isLoading: Bool = false
    var errorMessage: String?
    var titleError: String?
    var warningMessage: String?
    var showWarningDialog: Bool = false

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
            self.preAlarmOffsets = Set(alarm.preAlarmOffsets)
            self.soundName = alarm.soundName ?? UserSettings.shared.selectedAlarmSound
            self.followUpInterval = alarm.followUpInterval
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
            case .oneTime(let fireDate):
                self.oneTimeDate = fireDate
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearWarnings() {
        titleError = nil
    }

    /// Returns true if save proceeded, false if blocked by validation or warning dialog shown.
    @discardableResult
    func updateAlarm(context: ModelContext, existingAlarms: [Alarm]) -> Bool {
        guard let alarm else { return false }

        let schedule = buildSchedule()
        let result = AlarmValidator.validate(
            title: title,
            note: note,
            cycleType: cycleType,
            schedule: schedule,
            timesOfDay: timesOfDay,
            daysOfMonth: daysOfMonth,
            existingAlarms: existingAlarms,
            excludingAlarmID: alarm.id
        )

        // Hard errors block save
        if !result.isValid {
            if result.errors.contains(.emptyTitle) {
                titleError = "Alarm name is required."
            }
            if UserSettings.shared.hapticsEnabled {
                HapticService.shared.playError()
            }
            return false
        }

        // Soft warnings: show confirmation dialog
        let actionableWarnings = result.warnings.filter { $0 != .monthlyDay31 }
        if let firstWarning = actionableWarnings.first {
            warningMessage = firstWarning.displayMessage
            showWarningDialog = true
            return false
        }

        return performSave(context: context)
    }

    @discardableResult
    func forceSave(context: ModelContext) -> Bool {
        performSave(context: context)
    }

    private func performSave(context: ModelContext) -> Bool {
        guard let alarm else { return false }

        let trimmedTitle = AlarmValidator.trimmedTitle(title)
        let trimmedNote = AlarmValidator.trimmedNote(note)
        let schedule = buildSchedule()

        alarm.title = trimmedTitle
        alarm.cycleType = cycleType
        alarm.timesOfDay = timesOfDay
        alarm.schedule = schedule
        alarm.persistenceLevel = isPersistent ? .full : .notificationOnly
        alarm.note = trimmedNote
        alarm.preAlarmOffsets = Array(preAlarmOffsets)
        alarm.soundName = soundName == UserSettings.shared.selectedAlarmSound ? nil : soundName
        alarm.followUpInterval = followUpInterval
        alarm.category = category?.rawValue
        alarm.updatedAt = Date()
        if cycleType == .oneTime {
            let cal = Calendar.current
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
            alarm.nextFireDate = cal.date(
                bySettingHour: firstTime.hour, minute: firstTime.minute,
                second: 0, of: oneTimeDate
            ) ?? oneTimeDate
        } else if cycleType == .annual {
            let cal = Calendar.current
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
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
            if UserSettings.shared.hapticsEnabled {
                HapticService.shared.playSuccess()
            }
            titleError = nil
            warningMessage = nil
            showWarningDialog = false
            let alarmToSchedule = alarm
            Task {
                do {
                    try await AlarmScheduler.shared.cancelAlarm(alarmToSchedule)
                    if alarmToSchedule.isEnabled {
                        try await AlarmScheduler.shared.scheduleAlarm(alarmToSchedule)
                    }
                } catch {
                    // Reschedule failed — alarm will fire on next app launch
                }
                await CloudSyncService.shared.pushAlarmModel(alarmToSchedule)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAlarm(context: ModelContext) {
        guard let alarm else { return }
        AnalyticsService.shared.logEvent(AnalyticsEvent.alarmDeleted, parameters: [
            "cycle_type": alarm.cycleType.rawValue
        ])
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
                try? await CloudSyncService.shared.deleteRemoteAlarm(id: alarmIDString)
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
        case .oneTime:
            return .oneTime(fireDate: oneTimeDate)
        }
    }
}
