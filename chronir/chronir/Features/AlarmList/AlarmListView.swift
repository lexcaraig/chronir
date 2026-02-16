import SwiftUI
import SwiftData
import AppIntents
import AlarmKit

struct AlarmListView: View {
    @Query(sort: \Alarm.nextFireDate) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateAlarm = false
    @State private var enabledStates: [UUID: Bool] = [:]
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?
    @State private var showUpgradePrompt = false
    @State private var selectedCategoryFilter: AlarmCategory?
    @State private var selectedCategory: AlarmCategory?
    @State private var showArchived = false
    @State private var paywallViewModel = PaywallViewModel()
    private let subscriptionService = SubscriptionService.shared
    private var firingCoordinator = AlarmFiringCoordinator.shared
    private let alarmCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
        List {
            if paywallViewModel.isFreeTier && activeAlarms.count > (paywallViewModel.alarmLimit ?? Int.max) {
                Section {
                    HStack(spacing: SpacingTokens.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(ColorTokens.warning)
                        ChronirText(
                            "Your subscription has ended. Only your 2 oldest alarms remain active.",
                            style: .bodySmall,
                            color: ColorTokens.warning
                        )
                    }
                    .padding(SpacingTokens.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ColorTokens.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: SpacingTokens.xs, leading: SpacingTokens.md,
                        bottom: SpacingTokens.xs, trailing: SpacingTokens.md
                    ))
                }
            }

            if activeAlarms.isEmpty && archivedAlarms.isEmpty {
                EmptyStateView(onCreateAlarm: { requestCreateAlarm() })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                SiriTipView(intent: CreateAlarmIntent())
                    .siriTipViewStyle(.automatic)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.horizontal, SpacingTokens.md)
            } else {
                if !paywallViewModel.isFreeTier && !activeCategories.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            AdaptiveGlassContainer {
                                HStack(spacing: SpacingTokens.xs) {
                                    filterChip(label: "All", isSelected: selectedCategoryFilter == nil) {
                                        selectedCategoryFilter = nil
                                    }
                                    ForEach(activeCategories) { cat in
                                        filterChip(
                                            label: cat.displayName,
                                            icon: cat.iconName,
                                            color: cat.color,
                                            isSelected: selectedCategoryFilter == cat
                                        ) {
                                            selectedCategoryFilter = selectedCategoryFilter == cat ? nil : cat
                                        }
                                    }
                                }
                                .padding(.horizontal, SpacingTokens.md)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }

                if UserSettings.shared.groupAlarmsByCategory && !paywallViewModel.isFreeTier {
                    // Full section-header grouping with smart collapse
                    ForEach(smartGroupedItems, id: \.id) { item in
                        switch item {
                        case .grouped(let category, let alarms):
                            AdaptiveGlassContainer {
                                CategoryGroupCard(
                                    category: category,
                                    alarms: alarms,
                                    enabledStates: enabledStates
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { selectedCategory = category }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(
                                top: SpacingTokens.xxs, leading: SpacingTokens.md,
                                bottom: SpacingTokens.xxs, trailing: SpacingTokens.md
                            ))
                        case .individual(let alarm):
                            alarmRow(alarm)
                        }
                    }
                } else {
                    // Default flat list — all alarms as individual rows
                    ForEach(filteredAlarms) { alarm in
                        alarmRow(alarm)
                    }
                }

                if !archivedAlarms.isEmpty {
                    Section {
                        DisclosureGroup(
                            isExpanded: $showArchived
                        ) {
                            ForEach(archivedAlarms) { alarm in
                                alarmRow(alarm)
                            }
                        } label: {
                            HStack(spacing: SpacingTokens.xs) {
                                Image(systemName: "archivebox")
                                    .foregroundStyle(ColorTokens.textSecondary)
                                ChronirText(
                                    "Archived (\(archivedAlarms.count))",
                                    style: .labelLarge,
                                    color: ColorTokens.textSecondary
                                )
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .chronirWallpaperBackground()
        .navigationTitle("Alarms")
        .navigationDestination(item: $selectedAlarmID) { alarmID in
            AlarmDetailView(alarmID: alarmID)
        }
        .navigationDestination(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("NavBarLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: "settings") {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView(modelContext: modelContext)
        }
        .fullScreenCover(isPresented: $showUpgradePrompt) {
            PaywallView()
        }
        .navigationDestination(for: String.self) { destination in
            if destination == "settings" {
                SettingsView()
            }
        }
        .alert(
            "Delete Alarm",
            isPresented: Binding(
                get: { alarmToDelete != nil },
                set: { if !$0 { alarmToDelete = nil } }
            ),
            presenting: alarmToDelete
        ) { alarm in
            Button("Cancel", role: .cancel) {
                alarmToDelete = nil
            }
            Button("Delete", role: .destructive) {
                deleteAlarm(alarm)
                alarmToDelete = nil
            }
        } message: { alarm in
            Text("Are you sure you want to delete \"\(alarm.title)\"?")
        }
        .onAppear {
            refreshNextFireDates()
        }
        .onReceive(alarmCheckTimer) { _ in
            checkForFiringAlarms()
        }
        .onChange(of: firingCoordinator.isFiring) {
            if firingCoordinator.isFiring {
                showingCreateAlarm = false
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
        .onChange(of: subscriptionService.statusChecked) { _, checked in
            if checked { enforceAlarmLimit() }
        }
        .onChange(of: subscriptionService.currentTier) { _, _ in
            guard subscriptionService.statusChecked else { return }
            enforceAlarmLimit()
        }

        // FAB overlay
        AdaptiveGlassContainer {
            Button {
                requestCreateAlarm()
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .chronirGlassTintedCircle(tint: ColorTokens.primary)
            }
        }
        .padding(.bottom, SpacingTokens.lg)

        } // ZStack
    }

    private func checkForFiringAlarms() {
        guard !firingCoordinator.isFiring,
              !firingCoordinator.appIsInBackground else { return }
        let now = Date()
        let akAlarms = (try? AlarmManager.shared.alarms) ?? []
        for alarm in alarms {
            let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
            guard isEnabled, alarm.nextFireDate <= now,
                  !firingCoordinator.isHandled(alarm.id) else { continue }
            // Only present if AlarmKit confirms the alarm is actively alerting
            let akAlarm = akAlarms.first { $0.id == alarm.id }
            guard akAlarm?.state == .alerting else { continue }
            firingCoordinator.presentAlarm(id: alarm.id)
            break
        }
    }

    private func visualState(for alarm: Alarm) -> AlarmVisualState {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        if !isEnabled { return .inactive }
        if alarm.snoozeCount > 0 { return .snoozed }
        if alarm.nextFireDate < Date() { return .overdue }
        return .active
    }

    private func enabledBinding(for alarm: Alarm) -> Binding<Bool> {
        Binding(
            get: { enabledStates[alarm.id] ?? alarm.isEnabled },
            set: { newValue in
                if newValue && !canEnableMoreAlarms() {
                    showUpgradePrompt = true
                } else {
                    enabledStates[alarm.id] = newValue
                    if UserSettings.shared.hapticsEnabled {
                        HapticService.shared.playSelection()
                    }
                }
            }
        )
    }

    private func canEnableMoreAlarms() -> Bool {
        guard paywallViewModel.isFreeTier, let limit = paywallViewModel.alarmLimit else { return true }
        let enabledCount = activeAlarms.filter({ enabledStates[$0.id] ?? $0.isEnabled }).count
        return enabledCount < limit
    }

    private func alarmRow(_ alarm: Alarm) -> some View {
        AdaptiveGlassContainer {
            AlarmCard(
                alarm: alarm,
                visualState: visualState(for: alarm),
                isEnabled: enabledBinding(for: alarm),
                streak: subscriptionService.currentTier.rank >= SubscriptionTier.plus.rank
                    ? StreakCalculator.currentStreak(from: alarm.completionLogs)
                    : 0
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
            if !isEnabled && paywallViewModel.isFreeTier {
                showUpgradePrompt = true
            } else {
                selectedAlarmID = alarm.id
            }
        }
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
                if !current && !canEnableMoreAlarms() {
                    showUpgradePrompt = true
                } else {
                    enabledStates[alarm.id] = !current
                }
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

    private func filterChip(
        label: String,
        icon: String? = nil,
        color: Color = ColorTokens.primary,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: SpacingTokens.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .chronirFont(.labelSmall)
                }
                Text(label)
                    .chronirFont(.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .chronirGlassSelectableCapsule(isSelected: isSelected, tint: color)
        }
    }

    private var activeAlarms: [Alarm] {
        alarms.filter { !($0.cycleType == .oneTime && !$0.isEnabled) }
    }

    private var archivedAlarms: [Alarm] {
        alarms.filter { $0.cycleType == .oneTime && !$0.isEnabled }
    }

    private var filteredAlarms: [Alarm] {
        let source = activeAlarms
        guard let filter = selectedCategoryFilter else { return source }
        return source.filter { $0.alarmCategory == filter }
    }

    private var activeCategories: [AlarmCategory] {
        let cats = Set(activeAlarms.compactMap(\.alarmCategory))
        return AlarmCategory.allCases.filter { cats.contains($0) }
    }

    private enum SmartListItem: Identifiable {
        case grouped(AlarmCategory, [Alarm])
        case individual(Alarm)

        var id: String {
            switch self {
            case .grouped(let category, _): return "group-\(category.rawValue)"
            case .individual(let alarm): return "alarm-\(alarm.id.uuidString)"
            }
        }
    }

    private var smartGroupedItems: [SmartListItem] {
        let source = filteredAlarms
        let categorized = Dictionary(grouping: source) { $0.alarmCategory }
        var items: [SmartListItem] = []

        for cat in AlarmCategory.allCases {
            guard let alarms = categorized[cat], !alarms.isEmpty else { continue }
            if alarms.count >= 2 {
                items.append(.grouped(cat, alarms))
            } else {
                items.append(.individual(alarms[0]))
            }
        }

        // Uncategorized alarms are always individual
        if let uncategorized = categorized[nil] {
            for alarm in uncategorized {
                items.append(.individual(alarm))
            }
        }

        return items
    }

    private func requestCreateAlarm() {
        if paywallViewModel.canCreateAlarm(currentCount: activeAlarms.count) {
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
        try? modelContext.save()
    }

    private func refreshNextFireDates() {
        let calculator = DateCalculator()
        let now = Date()
        for alarm in alarms where alarm.isEnabled && alarm.cycleType != .oneTime && alarm.snoozeCount == 0 {
            let correct = calculator.calculateNextFireDate(for: alarm, from: now)
            if alarm.nextFireDate != correct {
                alarm.nextFireDate = correct
            }
        }
    }

    private func enforceAlarmLimit() {
        let tier = subscriptionService.currentTier
        if tier == .free, let limit = tier.alarmLimit {
            let enabled = activeAlarms.filter { enabledStates[$0.id] ?? $0.isEnabled }
            if enabled.count > limit {
                let sorted = enabled.sorted { $0.createdAt < $1.createdAt }
                for alarm in sorted.dropFirst(limit) {
                    enabledStates[alarm.id] = false
                }
            }
        } else if !tier.isFreeTier {
            for alarm in activeAlarms where !(enabledStates[alarm.id] ?? alarm.isEnabled) {
                enabledStates[alarm.id] = true
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
