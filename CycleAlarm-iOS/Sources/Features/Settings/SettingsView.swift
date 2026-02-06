import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        SingleColumnTemplate(title: "Settings") {
            Text("TODO: SettingsView")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
