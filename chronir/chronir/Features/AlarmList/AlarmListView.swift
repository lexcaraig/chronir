import SwiftUI
import TipKit
import SwiftData
import AppIntents
import AlarmKit

struct AlarmListView: View {
    @Query(sort: \Alarm.nextFireDate) private var alarms: [Alarm]
    @Query private var completionLogs: [CompletionLog]
    @AppStorage(FocusFilterStore.key, store: FocusFilterStore.defaults) private var focusCategoriesRaw = ""
    private let addWidgetTip = AddWidgetTip()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    var deepLinkAlarmID: Binding<UUID?>
    var deepLinkCreateAlarm: Binding<Bool>
    @State private var showingCreateAlarm = false

    init(deepLinkAlarmID: Binding<UUID?>, deepLinkCreateAlarm: Binding<Bool>) {
        self.deepLinkAlarmID = deepLinkAlarmID
        self.deepLinkCreateAlarm = deepLinkCreateAlarm
    }
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?
    @State private var alarmToSkip: Alarm?
    @State private var showUpgradePrompt = false
    @State private var selectedCategoryFilter: AlarmCategory?
    @State private var selectedCategory: AlarmCategory?
    @State private var showArchived = false
    @State private var paywallViewModel = PaywallViewModel()
    private let subscriptionService = SubscriptionService.shared
    private let schedulingStatus = AlarmSchedulingStatus.shared
    private var firingCoordinator = AlarmFiringCoordinator.shared
    private let alarmCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let streaks = AlarmRowActions.streaks(from: completionLogs)
        List {
            if !unscheduledAlarms.isEmpty {
                Section {
                    statusBanner(
                        icon: "exclamationmark.octagon.fill",
                        iconColor: ColorTokens.textError,
                        message: unscheduledMessage
                    ) {
                        Button("Try Again") { retryUnscheduled() }
                        Button("Open Settings") { openAppSettings() }
                    }
                }
            }

            if paywallViewModel.isFreeTier, let limit = paywallViewModel.alarmLimit, activeAlarms.count > limit {
                Section {
                    statusBanner(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: ColorTokens.textWarning,
                        message: "Your Plus subscription has ended. Only your \(limit) oldest alarms stay on; "
                            + "the rest were turned off."
                    ) {
                        Button("Resubscribe") { showUpgradePrompt = true }
                    }
                }
            }

            TipView(addWidgetTip)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if !focusCategoriesRaw.isEmpty {
                Section {
                    Label("Filtered by Focus", systemImage: "moon.fill")
                        .chronirFont(.bodySmall)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
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
                                        let colors = ChronirBadge.pair(for: cat)
                                        filterChip(
                                            label: cat.displayName,
                                            icon: cat.iconName,
                                            color: colors.background,
                                            selectedForeground: colors.foreground,
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
                                    enabledStates: [:]
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { selectedCategory = category }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("Shows the \(alarms.count) \(category.displayName) alarms")
                            .accessibilityAction(.default) { selectedCategory = category }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(
                                top: SpacingTokens.xxs, leading: SpacingTokens.md,
                                bottom: SpacingTokens.xxs, trailing: SpacingTokens.md
                            ))
                        case .individual(let alarm):
                            alarmRow(alarm, streaks: streaks)
                        }
                    }
                } else {
                    // Default flat list — all alarms as individual rows
                    ForEach(filteredAlarms) { alarm in
                        alarmRow(alarm, streaks: streaks)
                    }
                }

                if !archivedAlarms.isEmpty {
                    Section {
                        DisclosureGroup(
                            isExpanded: $showArchived
                        ) {
                            ForEach(archivedAlarms) { alarm in
                                alarmRow(alarm, streaks: streaks)
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
        .onChange(of: deepLinkAlarmID.wrappedValue) {
            if let id = deepLinkAlarmID.wrappedValue {
                if UserSettings.shared.groupAlarmsByCategory && !paywallViewModel.isFreeTier,
                   let alarm = activeAlarms.first(where: { $0.id == id }),
                   let category = alarm.alarmCategory,
                   activeAlarms.filter({ $0.alarmCategory == category }).count >= 2 {
                    selectedCategory = category
                } else {
                    selectedAlarmID = id
                }
                deepLinkAlarmID.wrappedValue = nil
            }
        }
        .onChange(of: activeAlarms.count, initial: true) { AddWidgetTip.alarmCount = activeAlarms.count }
        .onChange(of: deepLinkCreateAlarm.wrappedValue) {
            guard deepLinkCreateAlarm.wrappedValue else { return }
            deepLinkCreateAlarm.wrappedValue = false
            requestCreateAlarm()
        }
        .navigationDestination(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("NavBarLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: SpacingTokens.xl, height: SpacingTokens.xl)
                    .accessibilityHidden(true)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(value: "settings") {
                    Label("Settings", systemImage: "gear")
                }
                Button {
                    requestCreateAlarm()
                } label: {
                    Label("New Alarm", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView(modelContext: modelContext)
        }
        .fullScreenCover(isPresented: $showUpgradePrompt) {
            PaywallView(highlight: .unlimitedAlarms)
        }
        .navigationDestination(for: String.self) { destination in
            if destination == "settings" {
                SettingsView()
            }
        }
        .alarmRowConfirmations(alarmToDelete: $alarmToDelete, alarmToSkip: $alarmToSkip, context: modelContext)
        .onAppear {
            refreshNextFireDates()
            schedulingStatus.reconcile()
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
        .onChange(of: subscriptionService.statusChecked) { _, checked in
            if checked { enforceAlarmLimit() }
        }
        .onChange(of: subscriptionService.currentTier) { _, _ in
            guard subscriptionService.statusChecked else { return }
            enforceAlarmLimit()
        }
    }

    /// Fallback presenter for an alarm that is alerting while the list is on screen (the app-level
    /// `alarmUpdates` handler is the primary path). The in-memory pass is cheap; AlarmKit is only
    /// queried once an enabled alarm is actually due, not every second.
    private func checkForFiringAlarms() {
        guard !firingCoordinator.isFiring,
              !firingCoordinator.appIsInBackground else { return }
        let now = Date()
        let due = alarms.filter {
            $0.isEnabled && $0.nextFireDate <= now && !firingCoordinator.isHandled($0.id)
        }
        guard !due.isEmpty else { return }
        let akAlarms = (try? AlarmManager.shared.alarms) ?? []
        for alarm in due {
            // Only present if AlarmKit confirms the alarm is actively alerting
            let akAlarm = AlarmScheduler.activeRegistration(for: alarm.id, in: akAlarms)
            guard akAlarm?.state == .alerting else { continue }
            firingCoordinator.presentAlarm(id: alarm.id)
            break
        }
    }

    private func enabledBinding(for alarm: Alarm) -> Binding<Bool> {
        AlarmRowActions.enabledBinding(for: alarm, among: activeAlarms) { showUpgradePrompt = true }
    }

    private func alarmRow(_ alarm: Alarm, streaks: [UUID: Int]) -> some View {
        AlarmListRow(
            alarm: alarm,
            isEnabled: enabledBinding(for: alarm),
            streak: streaks[alarm.id] ?? 0,
            isPlusUser: subscriptionService.currentTier.rank >= SubscriptionTier.plus.rank,
            isUnscheduled: schedulingStatus.failedAlarmIDs.contains(alarm.id),
            onOpen: { selectedAlarmID = alarm.id },
            onDelete: { alarmToDelete = alarm },
            onSkip: { alarmToSkip = alarm },
            onConfirmDone: { AlarmRowActions.confirmPending(alarm, context: modelContext) }
        )
    }

    /// Banner row for list-level status (scheduling failure, subscription downgrade).
    private func statusBanner<Actions: View>(
        icon: String,
        iconColor: Color,
        message: String,
        @ViewBuilder actions: () -> Actions
    ) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack(alignment: .firstTextBaseline, spacing: SpacingTokens.sm) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .accessibilityHidden(true)
                ChronirText(message, style: .bodyMedium, color: ColorTokens.textPrimary)
            }
            HStack(spacing: SpacingTokens.lg) {
                actions()
            }
            .buttonStyle(.borderless)
            .chronirFont(.labelLarge)
            .foregroundStyle(ColorTokens.primary)
            .frame(minHeight: SpacingTokens.touchMinTarget)
        }
        .padding(SpacingTokens.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTokens.surfaceCard, in: RoundedRectangle(cornerRadius: RadiusTokens.md))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(
            top: SpacingTokens.xs, leading: SpacingTokens.md,
            bottom: SpacingTokens.xs, trailing: SpacingTokens.md
        ))
    }

    private var unscheduledAlarms: [Alarm] {
        alarms.filter { $0.isEnabled && schedulingStatus.failedAlarmIDs.contains($0.id) }
    }

    private var unscheduledMessage: String {
        let lead = unscheduledAlarms.count == 1
            ? "\"\(unscheduledAlarms[0].title)\" isn't scheduled and won't ring."
            : "\(unscheduledAlarms.count) alarms aren't scheduled and won't ring."
        return lead + " Check that Chronir is allowed to set alarms in Settings, then try again."
    }

    private func retryUnscheduled() {
        let pending = unscheduledAlarms
        Task {
            for alarm in pending {
                await schedulingStatus.schedule(alarm)
            }
        }
    }

    private func openAppSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
        #endif
    }

    private func filterChip(
        label: String,
        icon: String? = nil,
        color: Color = ColorTokens.primary,
        selectedForeground: Color = ColorTokens.onPrimary,
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
            .foregroundStyle(isSelected ? selectedForeground : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .frame(minHeight: SpacingTokens.touchMinTarget)
            .chronirGlassSelectableCapsule(isSelected: isSelected, tint: color)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var activeAlarms: [Alarm] {
        alarms.filter { !($0.cycleType == .oneTime && !$0.isEnabled && !$0.isPendingConfirmation) }
    }

    private var archivedAlarms: [Alarm] {
        alarms.filter { $0.cycleType == .oneTime && !$0.isEnabled && !$0.isPendingConfirmation }
    }

    /// Display-only: never use for tier enforcement or scheduling (those read `activeAlarms`).
    private var filteredAlarms: [Alarm] {
        let focusCategories = FocusFilterStore.parse(focusCategoriesRaw)
        let source = focusCategories.isEmpty ? activeAlarms : activeAlarms.filter {
            focusCategories.contains($0.alarmCategory?.rawValue ?? "")
        }
        let filtered = if let filter = selectedCategoryFilter {
            source.filter { $0.alarmCategory == filter }
        } else {
            source
        }
        let now = Date()
        return filtered.sorted { a, b in
            let aOverdue = a.isEnabled && a.nextFireDate < now
            let bOverdue = b.isEnabled && b.nextFireDate < now
            if aOverdue != bOverdue { return aOverdue }
            return a.nextFireDate < b.nextFireDate
        }
    }

    private var activeCategories: [AlarmCategory] {
        let cats = Set(activeAlarms.compactMap(\.alarmCategory))
        return AlarmCategory.allCases.filter { cats.contains($0) }
    }

}

// MARK: - Helpers

extension AlarmListView {
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

    private func refreshNextFireDates() {
        let calculator = DateCalculator()
        let now = Date()
        for alarm in alarms where alarm.isEnabled && alarm.cycleType != .oneTime && alarm.snoozeCount == 0 {
            guard alarm.nextFireDate >= now else { continue }
            let correct = calculator.calculateNextFireDate(for: alarm, from: now)
            if alarm.nextFireDate != correct {
                alarm.nextFireDate = correct
            }
        }
    }

    private func enforceAlarmLimit() {
        let tier = subscriptionService.currentTier
        if tier == .free, let limit = tier.alarmLimit {
            // Clear any pending confirmations on downgrade to Free
            for alarm in activeAlarms where alarm.isPendingConfirmation {
                PendingConfirmationService.shared.autoCompletePending(alarm: alarm)
            }
            let enabled = activeAlarms.filter(\.isEnabled)
            if enabled.count > limit {
                let sorted = enabled.sorted { $0.createdAt < $1.createdAt }
                for alarm in sorted.dropFirst(limit) {
                    AlarmRowActions.setEnabled(alarm, false)
                }
            }
        } else if !tier.isFreeTier {
            for alarm in activeAlarms where !alarm.isEnabled {
                AlarmRowActions.setEnabled(alarm, true)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        AlarmListView(deepLinkAlarmID: .constant(nil), deepLinkCreateAlarm: .constant(false))
    }
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        AlarmListView(deepLinkAlarmID: .constant(nil), deepLinkCreateAlarm: .constant(false))
    }
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.dark)
}
