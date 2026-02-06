import SwiftUI

@main
struct ChronirApp: App {
    // TODO: Add SwiftData modelContainer when models are finalized
    // TODO: Add Firebase configuration in init()
    // TODO: Replace with AlarmKit when Xcode 18/iOS 26 is available

    enum Tab {
        case alarms
        case settings
    }

    @State private var selectedTab: Tab = .alarms

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    AlarmListView()
                }
                .tabItem {
                    Label("Alarms", systemImage: "alarm")
                }
                .tag(Tab.alarms)

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
            }
            .tint(ColorTokens.primary)
        }
    }
}
