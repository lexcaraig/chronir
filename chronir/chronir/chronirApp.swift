import SwiftUI
import SwiftData

@main
struct ChronirApp: App {
    let container: ModelContainer
    @State private var coordinator = AlarmFiringCoordinator.shared
    @Bindable private var settings = UserSettings.shared

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
            .onAppear {
                NotificationService.shared.registerCategories()
            }
            .task {
                guard settings.hasCompletedOnboarding else { return }
                _ = try? await PermissionManager.shared.requestNotificationPermission()
                try? await AlarmScheduler.shared.rescheduleAllAlarms()
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
