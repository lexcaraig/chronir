import Foundation
@preconcurrency import AlarmKit
import SwiftUI
import os.signpost

private let perfLog = OSLog(subsystem: "com.chronir.ios", category: .pointsOfInterest)

protocol AlarmScheduling: Sendable {
    func scheduleAlarm(_ alarm: Alarm, refreshWidget: Bool) async throws
    func cancelAlarm(_ alarm: Alarm) async throws
    func rescheduleAllAlarms() async throws
}

extension AlarmScheduling {
    func scheduleAlarm(_ alarm: Alarm) async throws {
        try await scheduleAlarm(alarm, refreshWidget: true)
    }
}

final class AlarmScheduler: AlarmScheduling {
    static let shared = AlarmScheduler()

    private static let lastRescheduleKey = "chronir_last_reschedule"

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

    var shouldFullReschedule: Bool {
        guard let last = UserDefaults.standard.object(forKey: Self.lastRescheduleKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(last) > 900 // 15 minutes
    }

    private func markRescheduled() {
        UserDefaults.standard.set(Date(), forKey: Self.lastRescheduleKey)
    }

    func scheduleAlarm(_ alarm: Alarm, refreshWidget: Bool = true) async throws {
        if alarmManager.authorizationState != .authorized {
            let state = try await alarmManager.requestAuthorization()
            guard state == .authorized else { return }
        }

        let snoozeDuration: AlarmKit.Alarm.CountdownDuration? = alarm.isPersistent
            ? AlarmKit.Alarm.CountdownDuration(preAlert: nil, postAlert: 540) // 9-minute snooze
            : nil

        // Register a horizon of future occurrences, not just the next one.
        // The app is not launched when an AlarmKit alarm fires, so if iOS has
        // terminated the process, nothing in-app can schedule the following
        // occurrence. Pre-registering several keeps alarms firing for weeks
        // without the app ever being opened.
        var slots = dateCalculator.upcomingFireDates(
            for: alarm, from: Date(), count: Self.occurrenceHorizon
        )
        if alarm.snoozeCount > 0, !slots.isEmpty {
            // Snoozed: the primary registration fires at the snooze expiry.
            slots[0] = [alarm.nextFireDate] + slots[0].dropLast()
        }

        try await register(slots, for: alarm, snoozeDuration: snoozeDuration)

        // Schedule pre-alarm and backup notifications if enabled
        if alarm.snoozeCount == 0 {
            if !alarm.preAlarmOffsets.isEmpty {
                await notificationService.schedulePreAlarmNotifications(for: alarm)
            } else if alarm.preAlarmMinutes > 0 {
                await notificationService.schedulePreAlarmNotification(for: alarm)
            }
            await notificationService.scheduleBackupNotification(for: alarm)
        }

        if refreshWidget {
            await WidgetDataService.shared.refresh()
            await LiveActivityService.shared.refreshLiveActivity()
        }
    }

    private func register(
        _ slots: [[Date]], for alarm: Alarm,
        snoozeDuration: AlarmKit.Alarm.CountdownDuration?
    ) async throws {
        var idMap = Self.idMap
        defer { Self.idMap = idMap }
        // Registrations ringing or in snooze countdown are left alone; replacing one would cut it off.
        let active = Set(((try? alarmManager.alarms) ?? [])
            .filter { $0.state == .alerting || $0.state == .countdown }
            .map(\.id))
        for (slot, fireDates) in slots.enumerated() {
            for (occurrence, fireDate) in fireDates.enumerated() {
                let id = Self.registrationID(base: alarm.id, slot: slot, occurrence: occurrence)
                guard !active.contains(id) else { continue }
                // Replace, never duplicate: AlarmKit rejects an ID that is still registered (invalidInput).
                try? alarmManager.cancel(id: id)
                if id != alarm.id { idMap[id.uuidString] = alarm.id.uuidString }
                do {
                    _ = try await alarmManager.schedule(
                        id: id,
                        configuration: .init(
                            countdownDuration: snoozeDuration,
                            schedule: .fixed(fireDate),
                            attributes: buildAttributes(for: alarm),
                            stopIntent: StopAlarmIntent(registrationID: id),
                            secondaryIntent: alarm.isPersistent ? SnoozeAlarmIntent(registrationID: id) : nil
                        )
                    )
                } catch {
                    AnalyticsService.shared.recordError(error, context: "alarm_schedule")
                    throw error
                }
            }
        }
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

        do {
            _ = try await alarmManager.schedule(
                id: id,
                configuration: .init(
                    countdownDuration: snoozeDuration,
                    schedule: .fixed(fireDate),
                    attributes: buildAttributes(title: title, alarmID: id),
                    stopIntent: StopAlarmIntent(registrationID: id),
                    secondaryIntent: SnoozeAlarmIntent(registrationID: id)
                )
            )
        } catch {
            AnalyticsService.shared.recordError(error, context: "snooze_refire")
            throw error
        }
    }

    private func buildAttributes(title: String, alarmID: UUID, isPersistent: Bool = true) -> AlarmAttributes<AlarmMetadataPayload> {
        // Non-persistent alarms get no Snooze: with no countdown it would silence the alarm
        // without ever bringing it back.
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: title),
            stopButton: AlarmButton(text: "Done", textColor: .white, systemImageName: "checkmark.circle"),
            secondaryButton: isPersistent
                ? AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz")
                : nil,
            secondaryButtonBehavior: isPersistent ? .countdown : nil
        )

        let countdown = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: "Snoozed: \(title)")
        )

        let paused = AlarmPresentation.Paused(
            title: LocalizedStringResource(stringLiteral: "Paused: \(title)"),
            resumeButton: AlarmButton(text: "Resume", textColor: .white, systemImageName: "play.circle")
        )

        // AlarmKit rejects (invalidInput) a countdown presentation without a countdown duration,
        // and non-persistent alarms schedule with none.
        return AlarmAttributes(
            presentation: isPersistent
                ? AlarmPresentation(alert: alert, countdown: countdown, paused: paused)
                : AlarmPresentation(alert: alert),
            metadata: AlarmMetadataPayload(alarmID: alarmID.uuidString, title: title),
            tintColor: ColorTokens.primary
        )
    }

    private func buildAttributes(for alarm: Alarm) -> AlarmAttributes<AlarmMetadataPayload> {
        buildAttributes(title: alarm.title, alarmID: alarm.id, isPersistent: alarm.isPersistent)
    }

    func cancelAlarm(_ alarm: Alarm) async throws {
        var idMap = Self.idMap
        for id in Self.registrationIDs(for: alarm) {
            try? AlarmManager.shared.stop(id: id)
            try? AlarmManager.shared.cancel(id: id)
            idMap.removeValue(forKey: id.uuidString)
        }
        Self.idMap = idMap
        notificationService.cancelAllPreAlarmNotifications(for: alarm)
        await LiveActivityService.shared.refreshLiveActivity()
    }

    func rescheduleAllAlarms() async throws {
        os_signpost(.begin, log: perfLog, name: "rescheduleAllAlarms")
        defer { os_signpost(.end, log: perfLog, name: "rescheduleAllAlarms") }

        // Cancel ALL alarms first (including disabled/archived) to clear stale AlarmKit registrations,
        // but skip snoozed alarms — their AlarmKit countdown is still active.
        let allAlarms = try await repository.fetchAll()
        for alarm in allAlarms where alarm.snoozeCount == 0 {
            try await cancelAlarm(alarm)
        }

        // Reschedule all enabled, non-snoozed alarms.
        // Snoozed alarms retain their snooze countdown nextFireDate.
        // Always recalculate nextFireDate — past-due alarms must advance to the next occurrence.
        let now = Date()
        let enabledAlarms = allAlarms.filter { $0.isEnabled && $0.snoozeCount == 0 }
        var anyDateChanged = false
        for alarm in enabledAlarms {
            let newDate = dateCalculator.calculateNextFireDate(for: alarm, from: now)
            if alarm.nextFireDate != newDate {
                alarm.nextFireDate = newDate
                anyDateChanged = true
            }
            do {
                try await scheduleAlarm(alarm, refreshWidget: false)
            } catch {
                AnalyticsService.shared.recordError(error, context: "reschedule_alarm")
            }
        }

        if anyDateChanged {
            try await repository.saveChanges()
        }
        markRescheduled()
        await LiveActivityService.shared.refreshLiveActivity()
    }

    // MARK: - Audit

    /// Detect alarms that should be registered with AlarmKit but aren't, and re-register them.
    func auditAlarmRegistrations() async {
        let akAlarms = (try? AlarmManager.shared.alarms) ?? []
        let akIDs = Set(akAlarms.map { $0.id })
        let now = Date()

        let allAlarms = try? await repository.fetchAll()
        let needsScheduling = allAlarms?.filter { alarm in
            alarm.isEnabled &&
            alarm.snoozeCount == 0 &&
            alarm.nextFireDate > now &&
            !akIDs.contains(alarm.id)
        } ?? []

        for alarm in needsScheduling {
            do {
                try await scheduleAlarm(alarm, refreshWidget: false)
            } catch {
                AnalyticsService.shared.recordError(error, context: "audit_schedule_alarm")
            }
        }
        if !needsScheduling.isEmpty {
            await WidgetDataService.shared.refresh()
        }
    }

    // MARK: - Registration IDs

    /// Future occurrences registered with AlarmKit per time-of-day slot.
    static let occurrenceHorizon = 12

    private static let idMapKey = "chronir_alarmkit_id_map"

    /// Derived registration ID → base `Alarm.id`, persisted so AlarmKit events for
    /// derived registrations can be resolved back to the owning alarm.
    private static var idMap: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: idMapKey) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: idMapKey) }
    }

    /// Slot 0 / occurrence 0 is `base` itself, so the next fire of the first
    /// time slot keeps the alarm's own ID.
    static func registrationID(base: UUID, slot: Int, occurrence: Int) -> UUID {
        var bytes = base.uuid
        bytes.14 = UInt8(truncatingIfNeeded: Int(bytes.14) &+ occurrence)
        bytes.15 = UInt8(truncatingIfNeeded: Int(bytes.15) &+ slot)
        return UUID(uuid: bytes)
    }

    /// Every registration ID this alarm could currently hold.
    static func registrationIDs(for alarm: Alarm) -> [UUID] {
        (0..<max(1, alarm.timesOfDay.count)).flatMap { slot in
            (0..<occurrenceHorizon).map { registrationID(base: alarm.id, slot: slot, occurrence: $0) }
        }
    }

    /// Resolves an AlarmKit registration ID to the owning `Alarm.id`.
    static func baseAlarmID(for registrationID: UUID) -> UUID {
        idMap[registrationID.uuidString].flatMap(UUID.init) ?? registrationID
    }

    /// The registration currently alerting or in snooze countdown for an alarm, if any.
    static func activeRegistration(
        for baseID: UUID, in akAlarms: [AlarmKit.Alarm]
    ) -> AlarmKit.Alarm? {
        akAlarms.first {
            ($0.state == .alerting || $0.state == .countdown) && baseAlarmID(for: $0.id) == baseID
        }
    }

    /// Stops whichever registration of this alarm is alerting or counting down.
    static func stopActiveRegistration(for baseID: UUID) {
        let akAlarms = (try? AlarmManager.shared.alarms) ?? []
        if let active = activeRegistration(for: baseID, in: akAlarms) {
            try? AlarmManager.shared.stop(id: active.id)
        }
    }
}
