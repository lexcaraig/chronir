import SwiftUI
import SwiftData
import AlarmKit

@main
struct ChronirApp: App {
    let container: ModelContainer
    @State private var coordinator = AlarmFiringCoordinator.shared
    @Bindable private var settings = UserSettings.shared
    @Environment(\.scenePhase) private var scenePhase

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
            NavigationStack {
                AlarmListView()
            }
            .tint(ColorTokens.primary)
            .modelContainer(container)
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
                            // Alarm stopped or state cleared — dismiss if showing
                            await MainActor.run {
                                AlarmFiringCoordinator.shared.dismissFiring()
                            }
                        }
                    }
                }
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active,
                      coordinator.isFiring else { return }
                // App resumed — check if the alarm is still alerting.
                // alarmUpdates misses state changes while the app is suspended.
                Task {
                    let firingID = await coordinator.firingAlarmID
                    guard let alarms = try? AlarmManager.shared.alarms else {
                        await AlarmFiringCoordinator.shared.dismissFiring()
                        return
                    }
                    let stillAlerting = alarms.contains {
                        $0.id == firingID && $0.state == .alerting
                    }
                    if !stillAlerting {
                        await AlarmFiringCoordinator.shared.dismissFiring()
                    }
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
