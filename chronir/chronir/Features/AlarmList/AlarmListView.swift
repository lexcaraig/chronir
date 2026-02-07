import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.nextFireDate) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateAlarm = false
    @State private var showingSettings = false
    @State private var enabledStates: [UUID: Bool] = [:]
    @State private var selectedAlarmID: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SpacingTokens.md) {
                if alarms.isEmpty {
                    EmptyStateView(onCreateAlarm: { showingCreateAlarm = true })
                } else {
                    AlarmListSection(
                        title: "Upcoming",
                        alarms: alarms,
                        enabledStates: $enabledStates,
                        onAlarmSelected: { id in selectedAlarmID = id }
                    )
                }
            }
            .padding(.vertical, SpacingTokens.md)
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Alarms")
        .navigationDestination(item: $selectedAlarmID) { alarmID in
            AlarmDetailView(alarmID: alarmID)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingCreateAlarm = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(ColorTokens.primary)
                }
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { showingSettings = false }
                                .foregroundStyle(ColorTokens.primary)
                        }
                    }
            }
        }
        .onChange(of: enabledStates) {
            for (id, isEnabled) in enabledStates {
                if let alarm = alarms.first(where: { $0.id == id }) {
                    alarm.isEnabled = isEnabled
                    alarm.updatedAt = Date()
                    Task {
                        do {
                            if isEnabled {
                                alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())
                                try await AlarmScheduler.shared.scheduleAlarm(alarm)
                            } else {
                                try await AlarmScheduler.shared.cancelAlarm(alarm)
                            }
                        } catch {
                            print("Failed to toggle alarm notification: \(error)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlarmListView()
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
