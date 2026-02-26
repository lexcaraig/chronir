import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: AlarmCategory
    @Query(sort: \Alarm.nextFireDate) private var allAlarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var enabledStates: [UUID: Bool] = [:]
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?

    private var categoryAlarms: [Alarm] {
        allAlarms.filter { $0.alarmCategory == category }
    }

    var body: some View {
        List {
            if categoryAlarms.isEmpty {
                ContentUnavailableView(
                    "No Alarms",
                    systemImage: category.iconName,
                    description: Text("No alarms in \(category.displayName)")
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(categoryAlarms) { alarm in
                        alarmRow(alarm)
                    }
                } header: {
                    HStack(spacing: SpacingTokens.xs) {
                        Image(systemName: category.iconName)
                            .foregroundStyle(category.color)
                        ChronirText(
                            "\(categoryAlarms.count) alarm\(categoryAlarms.count == 1 ? "" : "s")",
                            style: .labelLarge,
                            color: ColorTokens.textSecondary
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
        .chronirWallpaperBackground()
        .navigationTitle(category.displayName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .navigationDestination(item: $selectedAlarmID) { alarmID in
            AlarmDetailView(alarmID: alarmID)
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
        .onChange(of: enabledStates) {
            for (id, isEnabled) in enabledStates {
                if let alarm = allAlarms.first(where: { $0.id == id }) {
                    alarm.isEnabled = isEnabled
                    alarm.updatedAt = Date()
                    Task {
                        do {
                            if isEnabled {
                                if alarm.nextFireDate < Date() {
                                    alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())
                                }
                                try await AlarmScheduler.shared.scheduleAlarm(alarm)
                            } else {
                                try await AlarmScheduler.shared.cancelAlarm(alarm)
                            }
                        } catch {
                            // Toggle failed — alarm state will reconcile on next launch
                        }
                    }
                }
            }
        }
    }

    private func visualState(for alarm: Alarm) -> AlarmVisualState {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        if !isEnabled { return .inactive }
        if alarm.isPendingConfirmation { return .pending }
        if alarm.snoozeCount > 0 { return .snoozed }
        return .active
    }

    private func enabledBinding(for alarm: Alarm) -> Binding<Bool> {
        Binding(
            get: { enabledStates[alarm.id] ?? alarm.isEnabled },
            set: { enabledStates[alarm.id] = $0 }
        )
    }

    private func alarmRow(_ alarm: Alarm) -> some View {
        AlarmCard(
            alarm: alarm,
            visualState: visualState(for: alarm),
            isEnabled: enabledBinding(for: alarm),
            streak: StreakCalculator.currentStreak(from: alarm.completionLogs),
            isPlusUser: SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
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
            if alarm.isPendingConfirmation {
                Button {
                    confirmPendingAlarm(alarm)
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
                .tint(ColorTokens.success)
            }
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

    private func confirmPendingAlarm(_ alarm: Alarm) {
        PendingConfirmationService.shared.confirmDone(alarm: alarm)
        try? modelContext.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }
        if UserSettings.shared.hapticsEnabled { HapticService.shared.playSuccess() }
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
        CategoryDetailView(category: .finance)
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
