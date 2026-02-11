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
            container = try ModelContainer(for: Alarm.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        AlarmRepository.configure(with: container)
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
                                AlarmFiringCoordinator.shared.presentAlarm(id: alarm.id)
                            }
                        case .countdown:
                            // User pressed Snooze on lock screen — dismiss in-app UI and track
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.dismissFiring()
                            }
                            if let repo = AlarmRepository.shared,
                               let model = try? await repo.fetch(by: alarm.id) {
                                model.snoozeCount += 1
                                try? await repo.update(model)
                            }
                        default:
                            // Alarm stopped from lock screen — complete it and dismiss
                            if let repo = AlarmRepository.shared,
                               let model = try? await repo.fetch(by: alarm.id) {
                                let calc = DateCalculator()
                                model.lastFiredDate = Date()
                                model.snoozeCount = 0
                                model.nextFireDate = calc.calculateNextFireDate(for: model, from: Date())
                                try? await repo.update(model)
                            }
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.dismissFiring()
                            }
                        }
                    }
                }
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Fires BEFORE scenePhase changes to .active, so we clear
                // firingAlarmID before SwiftUI re-renders the fullScreenCover.
                guard coordinator.isFiring else { return }
                let firingID = coordinator.firingAlarmID
                guard let alarms = try? AlarmManager.shared.alarms else {
                    coordinator.dismissFiring()
                    return
                }
                let stillAlerting = alarms.contains {
                    $0.id == firingID && $0.state == .alerting
                }
                if !stillAlerting {
                    if let firingID {
                        let context = container.mainContext
                        let targetID = firingID
                        let descriptor = FetchDescriptor<Alarm>(
                            predicate: #Predicate<Alarm> { $0.id == targetID }
                        )
                        if let model = try? context.fetch(descriptor).first {
                            let calc = DateCalculator()
                            model.lastFiredDate = Date()
                            model.snoozeCount = 0
                            model.nextFireDate = calc.calculateNextFireDate(for: model, from: Date())
                            try? context.save()
                        }
                    }
                    coordinator.dismissFiring()
                }
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

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
