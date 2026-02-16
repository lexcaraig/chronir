import Foundation
@preconcurrency import AlarmKit
import SwiftUI

protocol AlarmScheduling: Sendable {
    func scheduleAlarm(_ alarm: Alarm) async throws
    func cancelAlarm(_ alarm: Alarm) async throws
    func rescheduleAllAlarms() async throws
}

final class AlarmScheduler: AlarmScheduling {
    static let shared = AlarmScheduler()

    private let repository: AlarmRepositoryProtocol
    private let dateCalculator: DateCalculator
    private let alarmManager = AlarmManager.shared
    private let notificationService: NotificationServiceProtocol

    init(
        repository: AlarmRepositoryProtocol = AlarmRepository.shared,
        dateCalculator: DateCalculator = DateCalculator(),
        notificationService: NotificationServiceProtocol = NotificationService.shared
    ) {
        self.repository = repository
        self.dateCalculator = dateCalculator
        self.notificationService = notificationService
    }

    func scheduleAlarm(_ alarm: Alarm) async throws {
        if alarmManager.authorizationState != .authorized {
            let state = try await alarmManager.requestAuthorization()
            guard state == .authorized else { return }
        }

        let snoozeDuration = AlarmKit.Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: 540 // 9-minute snooze (matches iOS default)
        )

        let fireDates = dateCalculator.calculateNextFireDates(for: alarm, from: Date())
        let ids = alarmIDs(for: alarm)

        for (index, fireDate) in fireDates.enumerated() where index < ids.count {
            _ = try await alarmManager.schedule(
                id: ids[index],
                configuration: .init(
                    countdownDuration: snoozeDuration,
                    schedule: .fixed(fireDate),
                    attributes: buildAttributes(for: alarm)
                )
            )
        }

        // Schedule pre-alarm notification if enabled
        if alarm.preAlarmMinutes > 0 && alarm.snoozeCount == 0 {
            await notificationService.schedulePreAlarmNotification(for: alarm)
        }

        await WidgetDataService.shared.refresh()
    }

    /// Schedule a fresh AlarmKit alarm at the snooze expiry time.
    /// AlarmKit `.fixed()` schedules don't re-alert after a countdown ends,
    /// so we replace the countdown with a new alarm to get full system sound.
    func scheduleSnoozeRefire(id: UUID, title: String, at fireDate: Date) async throws {
        try? AlarmManager.shared.stop(id: id)
        try? AlarmManager.shared.cancel(id: id)

        if alarmManager.authorizationState != .authorized {
            let state = try await alarmManager.requestAuthorization()
            guard state == .authorized else { return }
        }

        let snoozeDuration = AlarmKit.Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: 540
        )

        _ = try await alarmManager.schedule(
            id: id,
            configuration: .init(
                countdownDuration: snoozeDuration,
                schedule: .fixed(fireDate),
                attributes: buildAttributes(title: title, alarmID: id)
            )
        )
    }

    private func buildAttributes(title: String, alarmID: UUID) -> AlarmAttributes<AlarmMetadataPayload> {
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: title),
            stopButton: AlarmButton(text: "Done", textColor: .white, systemImageName: "checkmark.circle"),
            secondaryButton: AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz"),
            secondaryButtonBehavior: .countdown
        )

        let countdown = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: "Snoozed: \(title)")
        )

        let paused = AlarmPresentation.Paused(
            title: LocalizedStringResource(stringLiteral: "Paused: \(title)"),
            resumeButton: AlarmButton(text: "Resume", textColor: .white, systemImageName: "play.circle")
        )

        return AlarmAttributes(
            presentation: AlarmPresentation(alert: alert, countdown: countdown, paused: paused),
            metadata: AlarmMetadataPayload(alarmID: alarmID.uuidString, title: title),
            tintColor: ColorTokens.primary
        )
    }

    private func buildAttributes(for alarm: Alarm) -> AlarmAttributes<AlarmMetadataPayload> {
        buildAttributes(title: alarm.title, alarmID: alarm.id)
    }

    func cancelAlarm(_ alarm: Alarm) async throws {
        for id in alarmIDs(for: alarm) {
            try? AlarmManager.shared.stop(id: id)
            try? AlarmManager.shared.cancel(id: id)
        }
        notificationService.cancelPreAlarmNotification(for: alarm)
    }

    func rescheduleAllAlarms() async throws {
        // Cancel ALL alarms first (including disabled/archived) to clear stale AlarmKit registrations,
        // but skip snoozed alarms — their AlarmKit countdown is still active.
        let allAlarms = try await repository.fetchAll()
        for alarm in allAlarms where alarm.snoozeCount == 0 {
            try await cancelAlarm(alarm)
        }

        // Only reschedule enabled, non-snoozed alarms.
        // Snoozed alarms retain their snooze countdown nextFireDate.
        let enabledAlarms = allAlarms.filter { $0.isEnabled && $0.snoozeCount == 0 }
        for alarm in enabledAlarms {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try await scheduleAlarm(alarm)
        }
    }

    // MARK: - Multi-time ID Derivation

    private func alarmIDs(for alarm: Alarm) -> [UUID] {
        let times = alarm.timesOfDay
        guard times.count > 1 else { return [alarm.id] }
        return times.indices.map { index in
            if index == 0 { return alarm.id }
            var bytes = alarm.id.uuid
            bytes.15 = UInt8(truncatingIfNeeded: Int(bytes.15) &+ index)
            return UUID(uuid: bytes)
        }
    }
}
