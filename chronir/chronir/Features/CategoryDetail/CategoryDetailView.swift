import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: AlarmCategory
    @Query(sort: \Alarm.nextFireDate) private var allAlarms: [Alarm]
    @Query private var completionLogs: [CompletionLog]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?
    @State private var alarmToSkip: Alarm?
    @State private var showUpgradePrompt = false
    private let schedulingStatus = AlarmSchedulingStatus.shared

    private var categoryAlarms: [Alarm] {
        allAlarms.filter { $0.alarmCategory == category }
    }

    var body: some View {
        let streaks = AlarmRowActions.streaks(from: completionLogs)
        let isPlusUser = SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
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
                        AlarmListRow(
                            alarm: alarm,
                            isEnabled: enabledBinding(for: alarm),
                            streak: streaks[alarm.id] ?? 0,
                            isPlusUser: isPlusUser,
                            isUnscheduled: schedulingStatus.failedAlarmIDs.contains(alarm.id),
                            onOpen: { selectedAlarmID = alarm.id },
                            onDelete: { alarmToDelete = alarm },
                            onSkip: { alarmToSkip = alarm },
                            onConfirmDone: { AlarmRowActions.confirmPending(alarm, context: modelContext) }
                        )
                    }
                } header: {
                    HStack(spacing: SpacingTokens.xs) {
                        Image(systemName: category.iconName)
                            .foregroundStyle(category.color)
                            .accessibilityHidden(true)
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
        .fullScreenCover(isPresented: $showUpgradePrompt) {
            PaywallView(highlight: .unlimitedAlarms)
        }
        .alarmRowConfirmations(alarmToDelete: $alarmToDelete, alarmToSkip: $alarmToSkip, context: modelContext)
    }

    private func enabledBinding(for alarm: Alarm) -> Binding<Bool> {
        AlarmRowActions.enabledBinding(for: alarm, among: allAlarms) { showUpgradePrompt = true }
    }
}

#Preview("Light") {
    NavigationStack {
        CategoryDetailView(category: .finance)
    }
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        CategoryDetailView(category: .finance)
    }
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.dark)
}
