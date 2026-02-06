import SwiftUI

@main
struct ChronirApp: App {
    // TODO: Add SwiftData modelContainer when models are finalized
    // TODO: Add Firebase configuration in init()
    // TODO: Replace with AlarmKit when Xcode 18/iOS 26 is available

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Text("Chronir")
                    .font(.largeTitle)
            }
        }
    }
}
