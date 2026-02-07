import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var snoozeEnabled = true
    @State private var slideToStopEnabled = false
    @State private var showComponentCatalog = false

    var body: some View {
        List {
            Section {
                ChronirToggle(label: "Snooze Enabled", isOn: $snoozeEnabled)
                ChronirToggle(label: "Slide to Stop", isOn: $slideToStopEnabled)
            } header: {
                ChronirText("Alarm Behavior", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                NavigationLink(destination: ComponentCatalog()) {
                    HStack {
                        ChronirText("Design System", style: .bodyPrimary)
                        Spacer()
                        ChronirIcon(systemName: "paintpalette", size: .small, color: ColorTokens.textSecondary)
                    }
                }
            } header: {
                ChronirText("Developer", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                HStack {
                    ChronirText("Version", style: .bodyPrimary)
                    Spacer()
                    ChronirText("1.0.0", style: .bodySecondary, color: ColorTokens.textSecondary)
                }
                HStack {
                    ChronirText("Privacy Policy", style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
                }
                HStack {
                    ChronirText("Terms of Service", style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
                }
            } header: {
                ChronirText("About", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
