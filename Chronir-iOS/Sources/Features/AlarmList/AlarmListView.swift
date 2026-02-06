import SwiftUI

struct AlarmListView: View {
    @State private var viewModel = AlarmListViewModel()
    @State private var showingCreateAlarm = false
    @State private var enabledStates: [UUID: Bool] = [:]

    var body: some View {
        SingleColumnTemplate(title: "Alarms") {
            if viewModel.alarms.isEmpty {
                EmptyStateView(onCreateAlarm: { showingCreateAlarm = true })
            } else {
                AlarmListSection(
                    title: "Upcoming",
                    alarms: viewModel.alarms,
                    enabledStates: $enabledStates,
                    onDelete: { alarm in
                        Task { await viewModel.deleteAlarm(alarm) }
                    }
                )
            }
        } floatingAction: {
            if !viewModel.alarms.isEmpty {
                Button(
                    action: { showingCreateAlarm = true },
                    label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(ColorTokens.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                )
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView()
        }
        .task {
            await viewModel.loadAlarms()
        }
        .onChange(of: enabledStates) {
            for (id, isEnabled) in enabledStates {
                Task { await viewModel.toggleAlarm(id: id, isEnabled: isEnabled) }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlarmListView()
    }
}
