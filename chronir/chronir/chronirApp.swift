import SwiftUI
import SwiftData

@main
struct ChronirApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Alarm.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AlarmListView()
            }
            .tint(ColorTokens.primary)
            .modelContainer(container)
            .task {
                _ = try? await PermissionManager.shared.requestNotificationPermission()
            }
        }
    }
}
