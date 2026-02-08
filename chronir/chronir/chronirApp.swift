import SwiftUI
import SwiftData

@main
struct ChronirApp: App {
    let container: ModelContainer
    @State private var coordinator = AlarmFiringCoordinator.shared

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
                _ = try? await PermissionManager.shared.requestNotificationPermission()
                try? await AlarmScheduler.shared.rescheduleAllAlarms()
            }
            .fullScreenCover(item: $coordinator.firingAlarmID) { alarmID in
                AlarmFiringView(alarmID: alarmID)
                    .modelContainer(container)
            }
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
