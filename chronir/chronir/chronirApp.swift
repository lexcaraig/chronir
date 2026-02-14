import SwiftUI
import SwiftData
import AlarmKit
import StoreKit
import AppIntents
#if canImport(UIKit)
import UIKit
#endif

@main
struct ChronirApp: App {
    let container: ModelContainer
    @State private var coordinator = AlarmFiringCoordinator.shared
    @Bindable private var settings = UserSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true

    init() {
        do {
            container = try ModelContainer(for: Alarm.self, CompletionLog.self)
        } catch {
            // Corrupted store — delete and recreate to avoid permanent crash loop
            let defaultURL = URL.applicationSupportDirectory
                .appendingPathComponent("default.store")
            try? FileManager.default.removeItem(at: defaultURL)
            do {
                container = try ModelContainer(for: Alarm.self, CompletionLog.self)
            } catch {
                fatalError("Failed to create ModelContainer after recovery: \(error)")
            }
        }
        AlarmRepository.configure(with: container)
        Self.migrateCompletionRecords(container: container)
        ChronirShortcuts.updateAppShortcutParameters()
    }

    /// One-time migration of legacy CompletionRecord from UserDefaults to SwiftData.
    private static func migrateCompletionRecords(container: ModelContainer) {
        let key = "completionRecords"
        guard let data = UserDefaults.standard.data(forKey: key),
              let legacy = try? JSONDecoder().decode([LegacyCompletionRecord].self, from: data),
              !legacy.isEmpty else {
            return
        }
        let context = container.mainContext
        for record in legacy {
            let log = CompletionLog(
                id: record.id,
                alarmID: record.alarmID,
                scheduledDate: record.completedAt,
                completedAt: record.completedAt,
                action: record.action
            )
            // Link to alarm if it still exists
            let targetID = record.alarmID
            let descriptor = FetchDescriptor<Alarm>(
                predicate: #Predicate<Alarm> { $0.id == targetID }
            )
            if let alarm = try? context.fetch(descriptor).first {
                log.alarm = alarm
            }
            context.insert(log)
        }
        try? context.save()
        UserDefaults.standard.removeObject(forKey: key)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    AlarmListView()
                }

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .environment(\.textSizeScale, settings.textSizePreference.scaleFactor)
            .tint(ColorTokens.primary)
            .task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
            .modelContainer(container)
            .task {
                SubscriptionService.shared.listenForTransactions()
                await SubscriptionService.shared.updateSubscriptionStatus()
            }
            .task {
                guard settings.hasCompletedOnboarding else { return }
                _ = await PermissionManager.shared.requestAlarmPermission()
                try? await AlarmScheduler.shared.rescheduleAllAlarms()
            }
            .task {
                for await alarms in AlarmManager.shared.alarmUpdates {
                    for alarm in alarms {
                        switch alarm.state {
                        case .alerting:
                            await MainActor.run {
                                // Skip if the app is returning from background —
                                // the foreground handler is the sole decision-maker.
                                guard !AlarmFiringCoordinator.shared.appIsInBackground else { return }
                                // Skip if the foreground handler already processed this alarm
                                // (stale buffered event arriving after appIsInBackground was cleared).
                                guard !AlarmFiringCoordinator.shared.isHandled(alarm.id) else { return }
                                // Skip if the alarm is disabled/archived (stale AlarmKit registration)
                                let targetID = alarm.id
                                let descriptor = FetchDescriptor<Alarm>(
                                    predicate: #Predicate<Alarm> { $0.id == targetID && $0.isEnabled == true }
                                )
                                guard (try? self.container.mainContext.fetch(descriptor).first) != nil else {
                                    try? AlarmManager.shared.stop(id: alarm.id)
                                    try? AlarmManager.shared.cancel(id: alarm.id)
                                    return
                                }
                                AlarmFiringCoordinator.shared.presentAlarm(id: alarm.id)
                            }
                        case .countdown:
                            // Snoozed — track for foreground handler, dismiss firing UI,
                            // and update model so the alarm card shows the snooze countdown.
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.snoozedInBackground.insert(alarm.id)
                                AlarmFiringCoordinator.shared.dismissFiring()
                                let targetID = alarm.id
                                let descriptor = FetchDescriptor<Alarm>(
                                    predicate: #Predicate<Alarm> { $0.id == targetID }
                                )
                                if let model = try? self.container.mainContext.fetch(descriptor).first,
                                   model.nextFireDate <= Date() {
                                    // Guard: only process if not already handled (race with foreground handler)
                                    model.snoozeCount += 1
                                    model.nextFireDate = Date().addingTimeInterval(540)
                                    let log = CompletionLog(
                                        alarmID: model.id,
                                        scheduledDate: model.nextFireDate,
                                        action: .snoozed,
                                        snoozeCount: model.snoozeCount
                                    )
                                    log.alarm = model
                                    self.container.mainContext.insert(log)
                                    try? self.container.mainContext.save()
                                }
                            }
                        default:
                            await MainActor.run {
                                // If this alarm was snoozed and its countdown just ended
                                // without re-alerting, present the firing view ourselves.
                                // (AlarmKit .fixed() schedules don't re-alert after snooze.)
                                if AlarmFiringCoordinator.shared.snoozedInBackground.remove(alarm.id) != nil {
                                    let targetID = alarm.id
                                    let descriptor = FetchDescriptor<Alarm>(
                                        predicate: #Predicate<Alarm> { $0.id == targetID && $0.isEnabled == true }
                                    )
                                    if (try? self.container.mainContext.fetch(descriptor).first) != nil {
                                        AlarmFiringCoordinator.shared.presentAlarm(id: alarm.id)
                                    }
                                } else {
                                    AlarmFiringCoordinator.shared.dismissFiring()
                                }
                            }
                        }
                    }
                }
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                AlarmFiringCoordinator.shared.appIsInBackground = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                let akAlarms = (try? AlarmManager.shared.alarms) ?? []

                let context = container.mainContext
                let now = Date()

                // Case 1: Firing screen was up before backgrounding
                // Data is handled by completeIfNeeded() via onDisappear — just dismiss here.
                if coordinator.isFiring, let firingID = coordinator.firingAlarmID {
                    let akAlarm = akAlarms.first { $0.id == firingID }
                    if akAlarm?.state != .alerting {
                        coordinator.dismissFiring()
                    }
                }

                // Case 2: Alarm fired while app was fully backgrounded
                let enabledDesc = FetchDescriptor<Alarm>(
                    predicate: #Predicate<Alarm> { $0.isEnabled == true }
                )
                if let models = try? context.fetch(enabledDesc) {
                    let pastDue = models.filter { $0.nextFireDate < now }
                    for model in pastDue {
                        // Skip if ViewModel's completeIfNeeded() already handled this
                        guard !coordinator.isHandled(model.id) else { continue }

                        let akAlarm = akAlarms.first { $0.id == model.id }

                        if akAlarm?.state == .alerting {
                            coordinator.presentAlarm(id: model.id)
                        } else if akAlarm?.state == .countdown {
                            // Still in snooze countdown — process if not already by .countdown handler
                            if model.nextFireDate <= now {
                                handleLockScreenAction(
                                    model: model,
                                    wasSnoozed: true,
                                    context: context
                                )
                            }
                            coordinator.markHandled(model.id)
                        } else if coordinator.snoozedInBackground.contains(model.id) {
                            // Snooze countdown ended while backgrounded — re-present
                            // (AlarmKit .fixed() schedules don't re-alert after snooze)
                            coordinator.snoozedInBackground.remove(model.id)
                            coordinator.presentAlarm(id: model.id)
                        } else {
                            // Lock screen stop (not snoozed)
                            handleLockScreenAction(
                                model: model,
                                wasSnoozed: false,
                                context: context
                            )
                            coordinator.snoozedInBackground.remove(model.id)
                            coordinator.markHandled(model.id)
                        }
                    }
                }

                // Re-enable alarmUpdates presentation now that stale events have been processed.
                coordinator.appIsInBackground = false
            }
            #endif
            .onChange(of: scenePhase) {
                // Fallback for edge cases where willEnterForeground didn't fire.
                guard scenePhase == .active,
                      coordinator.isFiring else { return }
                guard let alarms = try? AlarmManager.shared.alarms else {
                    coordinator.dismissFiring()
                    return
                }
                let stillAlerting = alarms.contains {
                    $0.id == coordinator.firingAlarmID && $0.state == .alerting
                }
                if !stillAlerting {
                    coordinator.dismissFiring()
                }
            }
            .fullScreenCover(item: $coordinator.firingAlarmID) { alarmID in
                AlarmFiringView(alarmID: alarmID)
            }
            .sheet(isPresented: Binding(
                get: { !settings.hasCompletedOnboarding },
                set: { if !$0 { settings.hasCompletedOnboarding = true } }
            )) {
                OnboardingView()
                    .interactiveDismissDisabled()
            }
        }
    }
}

// MARK: - Lock Screen Action Handling

extension ChronirApp {
    /// Processes a lock screen snooze or stop for a given alarm model.
    /// Must be called on the main context.
    @MainActor
    private func handleLockScreenAction(
        model: Alarm,
        wasSnoozed: Bool,
        context: ModelContext
    ) {
        if wasSnoozed {
            // Lock screen snooze
            model.snoozeCount += 1
            model.nextFireDate = Date().addingTimeInterval(540) // matches postAlert snooze duration
            let log = CompletionLog(
                alarmID: model.id,
                scheduledDate: model.nextFireDate,
                action: .snoozed,
                snoozeCount: model.snoozeCount
            )
            log.alarm = model
            context.insert(log)
        } else {
            // Lock screen stop
            let calc = DateCalculator()
            let log = CompletionLog(
                alarmID: model.id,
                scheduledDate: model.nextFireDate,
                action: .completed,
                snoozeCount: model.snoozeCount
            )
            log.alarm = model
            context.insert(log)
            model.lastFiredDate = Date()
            model.snoozeCount = 0
            if model.cycleType == .oneTime {
                model.isEnabled = false
                model.nextFireDate = .distantFuture
            } else {
                model.nextFireDate = calc.calculateNextFireDate(for: model, from: Date())
            }
        }
        try? context.save()
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
