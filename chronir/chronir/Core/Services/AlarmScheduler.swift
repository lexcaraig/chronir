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

    init(
        repository: AlarmRepositoryProtocol = AlarmRepository.shared,
        dateCalculator: DateCalculator = DateCalculator()
    ) {
        self.repository = repository
        self.dateCalculator = dateCalculator
    }

    func scheduleAlarm(_ alarm: Alarm) async throws {
        // Ensure authorization before scheduling
        if alarmManager.authorizationState != .authorized {
            let state = try await alarmManager.requestAuthorization()
            guard state == .authorized else { return }
        }

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: alarm.title),
            stopButton: AlarmButton(
                text: "Done",
                textColor: .white,
                systemImageName: "checkmark.circle"
            ),
            secondaryButton: AlarmButton(
                text: "Snooze",
                textColor: .white,
                systemImageName: "zzz"
            ),
            secondaryButtonBehavior: .custom
        )

        let metadata = AlarmMetadataPayload(
            alarmID: alarm.id.uuidString,
            title: alarm.title
        )

        let attributes = AlarmAttributes(
            presentation: AlarmPresentation(alert: alert),
            metadata: metadata,
            tintColor: ColorTokens.primary
        )

        let schedule = AlarmKit.Alarm.Schedule.fixed(alarm.nextFireDate)

        _ = try await alarmManager.schedule(
            id: alarm.id,
            configuration: .alarm(
                schedule: schedule,
                attributes: attributes
            )
        )
    }

    func cancelAlarm(_ alarm: Alarm) async throws {
        try AlarmManager.shared.cancel(id: alarm.id)
    }

    func rescheduleAllAlarms() async throws {
        let alarms = try await repository.fetchEnabled()
        for alarm in alarms {
            alarm.nextFireDate = dateCalculator.calculateNextFireDate(for: alarm, from: Date())
            try await scheduleAlarm(alarm)
        }
    }
}
