import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.nextFireDate) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateAlarm = false
    @State private var showingSettings = false
    @State private var enabledStates: [UUID: Bool] = [:]
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?
    @State private var showUpgradePrompt = false
    @State private var paywallViewModel = PaywallViewModel()
    private var firingCoordinator = AlarmFiringCoordinator.shared

    var body: some View {
        List {
            if alarms.isEmpty {
                EmptyStateView(onCreateAlarm: { requestCreateAlarm() })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            } else {
                Section {
                    ForEach(alarms) { alarm in
                        AlarmCard(
                            alarm: alarm,
                            visualState: visualState(for: alarm),
                            isEnabled: enabledBinding(for: alarm)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { selectedAlarmID = alarm.id }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(
                            top: SpacingTokens.xxs, leading: SpacingTokens.md,
                            bottom: SpacingTokens.xxs, trailing: SpacingTokens.md
                        ))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                alarmToDelete = alarm
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                selectedAlarmID = alarm.id
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(ColorTokens.info)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                let current = enabledStates[alarm.id] ?? alarm.isEnabled
                                enabledStates[alarm.id] = !current
                            } label: {
                                let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
                                Label(
                                    isEnabled ? "Disable" : "Enable",
                                    systemImage: isEnabled ? "bell.slash" : "bell"
                                )
                            }
                            .tint(
                            enabledStates[alarm.id] ?? alarm.isEnabled
                            ? ColorTokens.textSecondary : ColorTokens.success
                        )
                        }
                    }
                } header: {
                    HStack(spacing: SpacingTokens.xs) {
                        ChronirText(
                            "UPCOMING",
                            style: .labelLarge,
                            color: ColorTokens.textSecondary
                        )
                        ChronirBadge("\(alarms.count)", color: ColorTokens.backgroundTertiary)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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
                    requestCreateAlarm()
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
        .sheet(isPresented: $showUpgradePrompt) {
            PaywallView()
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
        .confirmationDialog(
            "Delete Alarm",
            isPresented: Binding(
                get: { alarmToDelete != nil },
                set: { if !$0 { alarmToDelete = nil } }
            ),
            presenting: alarmToDelete
        ) { alarm in
            Button("Delete", role: .destructive) {
                deleteAlarm(alarm)
                alarmToDelete = nil
            }
        } message: { alarm in
            Text("Are you sure you want to delete \"\(alarm.title)\"?")
        }
        .onChange(of: firingCoordinator.isFiring) {
            if firingCoordinator.isFiring {
                showingCreateAlarm = false
                showingSettings = false
                showUpgradePrompt = false
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

    private func visualState(for alarm: Alarm) -> AlarmVisualState {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        if !isEnabled { return .inactive }
        if alarm.nextFireDate < Date() { return .overdue }
        return .active
    }

    private func enabledBinding(for alarm: Alarm) -> Binding<Bool> {
        Binding(
            get: { enabledStates[alarm.id] ?? alarm.isEnabled },
            set: { enabledStates[alarm.id] = $0 }
        )
    }

    private func requestCreateAlarm() {
        if paywallViewModel.canCreateAlarm(currentCount: alarms.count) {
            showingCreateAlarm = true
        } else {
            showUpgradePrompt = true
        }
    }

    private func deleteAlarm(_ alarm: Alarm) {
        Task {
            try? await AlarmScheduler.shared.cancelAlarm(alarm)
        }
        modelContext.delete(alarm)
    }
}

#Preview {
    NavigationStack {
        AlarmListView()
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
