import SwiftUI
import SwiftData
import AlarmKit
import StoreKit
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
            fatalError("Failed to create ModelContainer: \(error)")
        }
        AlarmRepository.configure(with: container)
        Self.migrateCompletionRecords(container: container)
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
                                AlarmFiringCoordinator.shared.presentAlarm(id: alarm.id)
                            }
                        case .countdown:
                            // Snoozed — track for foreground handler, dismiss firing UI
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.snoozedInBackground.insert(alarm.id)
                                AlarmFiringCoordinator.shared.dismissFiring()
                            }
                        default:
                            // Stopped or rescheduled — dismiss firing UI only
                            // Data updates handled by foreground handler or ViewModel
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.dismissFiring()
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
                        } else {
                            // Snoozed only if .countdown was seen OR alarm is actively in countdown
                            let wasSnoozed = coordinator.snoozedInBackground.contains(model.id)
                                || akAlarm?.state == .countdown
                            handleLockScreenAction(
                                model: model,
                                wasSnoozed: wasSnoozed,
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
                    .modelContainer(container)
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
            model.nextFireDate = calc.calculateNextFireDate(for: model, from: Date())
        }
        try? context.save()
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
