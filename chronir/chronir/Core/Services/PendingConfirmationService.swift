import Foundation
@preconcurrency import UserNotifications

@MainActor
final class PendingConfirmationService {
    static let shared = PendingConfirmationService()

    /// Posted when the user taps "Done" on a pending confirmation notification.
    /// Object is the alarm UUID string.
    static let didConfirmFromNotification = Notification.Name("PendingConfirmationService.didConfirm")

    private static let categoryID = "PENDING_CONFIRMATION"
    private static let actionDone = "PENDING_DONE"
    private static let actionRemind = "PENDING_REMIND"

    private let notificationCenter = UNUserNotificationCenter.current()
    private let dateCalculator = DateCalculator()

    private init() {}

    // MARK: - Category Registration

    func registerNotificationCategory() async {
        let doneAction = UNNotificationAction(
            identifier: Self.actionDone,
            title: "Done",
            options: [.authenticationRequired]
        )
        let remindAction = UNNotificationAction(
            identifier: Self.actionRemind,
            title: "Remind Me",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryID,
            actions: [doneAction, remindAction],
            intentIdentifiers: []
        )
        // Merge with existing categories to avoid overwriting other registrations
        let existing = await notificationCenter.notificationCategories()
        var merged = existing.filter { $0.identifier != Self.categoryID }
        merged.insert(category)
        notificationCenter.setNotificationCategories(merged)
    }

    // MARK: - Enter Pending

    func enterPending(alarm: Alarm) async {
        // Capture the original fire date before rescheduling
        let originalFireDate = alarm.nextFireDate

        alarm.isPendingConfirmation = true
        alarm.pendingSince = Date()
        alarm.lastFiredDate = Date()
        alarm.snoozeCount = 0

        // Reschedule next occurrence
        if alarm.cycleType == .oneTime {
            alarm.isEnabled = false
            alarm.nextFireDate = .distantFuture
            try? await AlarmScheduler.shared.cancelAlarm(alarm)
        } else {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try? await AlarmScheduler.shared.cancelAlarm(alarm)
            try? await AlarmScheduler.shared.scheduleAlarm(alarm)
        }

        // Log the pending action with the original (not rescheduled) fire date
        if let repo = AlarmRepository.shared {
            let log = CompletionLog(
                alarmID: alarm.id,
                scheduledDate: originalFireDate,
                action: .pendingConfirmation,
                snoozeCount: 0
            )
            try? await repo.saveCompletionLog(log)
        }

        // Schedule follow-up notifications
        await scheduleFollowUpNotifications(for: alarm)
    }

    // MARK: - Confirm Done

    func confirmDone(alarm: Alarm) {
        guard alarm.isPendingConfirmation else { return }
        alarm.isPendingConfirmation = false
        alarm.pendingSince = nil
        alarm.lastCompletedAt = Date()

        cancelFollowUpNotifications(for: alarm)

        // Log completion
        let log = CompletionLog(
            alarmID: alarm.id,
            scheduledDate: alarm.nextFireDate,
            action: .completed,
            snoozeCount: 0
        )
        if let repo = AlarmRepository.shared {
            Task { try? await repo.saveCompletionLog(log) }
        }

        AppReviewService.recordCompletion()
    }

    // MARK: - Cancel Pending

    func cancelPending(alarm: Alarm) {
        alarm.isPendingConfirmation = false
        alarm.pendingSince = nil
        cancelFollowUpNotifications(for: alarm)
    }

    // MARK: - Auto-Complete (next occurrence fires while still pending)

    func autoCompletePending(alarm: Alarm) {
        guard alarm.isPendingConfirmation else { return }
        alarm.isPendingConfirmation = false
        alarm.pendingSince = nil
        alarm.lastCompletedAt = Date()
        cancelFollowUpNotifications(for: alarm)

        let log = CompletionLog(
            alarmID: alarm.id,
            scheduledDate: alarm.nextFireDate,
            action: .completed,
            snoozeCount: 0
        )
        if let repo = AlarmRepository.shared {
            Task { try? await repo.saveCompletionLog(log) }
        }
    }

    // MARK: - Tier Check

    var isPlusUser: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    // MARK: - Notification Action Handling

    /// Called from NotificationService.didReceive when the user responds to a pending confirmation notification.
    nonisolated static func handleNotificationAction(actionIdentifier: String, alarmIDString: String) {
        guard actionIdentifier == actionDone else { return } // "Remind Me" is a no-op
        NotificationCenter.default.post(
            name: didConfirmFromNotification,
            object: alarmIDString
        )
    }

    // MARK: - Private

    private func scheduleFollowUpNotifications(for alarm: Alarm) async {
        let offsets: [TimeInterval] = [30 * 60, 60 * 60, 90 * 60] // +30m, +60m, +90m

        for (index, offset) in offsets.enumerated() {
            let fireDate = Date().addingTimeInterval(offset)

            let content = UNMutableNotificationContent()
            content.title = "Did you complete it?"
            content.body = "\"\(alarm.title)\" is awaiting confirmation"
            content.sound = .default
            content.categoryIdentifier = Self.categoryID
            content.userInfo = ["alarmID": alarm.id.uuidString]

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "pending-confirm-\(alarm.id.uuidString)-\(index)",
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                // Notification scheduling failed — pending state still persists in model
            }
        }
    }

    private func cancelFollowUpNotifications(for alarm: Alarm) {
        let ids = (0..<3).map { "pending-confirm-\(alarm.id.uuidString)-\($0)" }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
