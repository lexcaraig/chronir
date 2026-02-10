import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.nextFireDate) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateAlarm = false
    @State private var enabledStates: [UUID: Bool] = [:]
    @State private var selectedAlarmID: UUID?
    @State private var alarmToDelete: Alarm?
    @State private var showUpgradePrompt = false
    @State private var isGroupedByCategory = false
    @State private var selectedCategoryFilter: AlarmCategory?
    @State private var selectedCategory: AlarmCategory?
    @State private var paywallViewModel = PaywallViewModel()
    private var firingCoordinator = AlarmFiringCoordinator.shared
    private let alarmCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
        List {
            if alarms.isEmpty {
                EmptyStateView(onCreateAlarm: { requestCreateAlarm() })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            } else {
                if !paywallViewModel.isFreeTier && !activeCategories.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            GlassEffectContainer {
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

                if isGroupedByCategory && !paywallViewModel.isFreeTier {
                    // Full section-header grouping with smart collapse
                    ForEach(smartGroupedItems, id: \.id) { item in
                        switch item {
                        case .grouped(let category, let alarms):
                            GlassEffectContainer {
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
                    // Default view: auto-collapse categories with 2+ alarms
                    ForEach(smartGroupedItems, id: \.id) { item in
                        switch item {
                        case .grouped(let category, let alarms):
                            GlassEffectContainer {
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
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: SpacingTokens.sm) {
                    if !paywallViewModel.isFreeTier {
                        Button {
                            isGroupedByCategory.toggle()
                        } label: {
                            Image(systemName: isGroupedByCategory ? "list.bullet" : "rectangle.3.group")
                        }
                    }
                    NavigationLink(value: "settings") {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView(modelContext: modelContext)
        }
        .sheet(isPresented: $showUpgradePrompt) {
            PaywallView()
        }
        .navigationDestination(for: String.self) { destination in
            if destination == "settings" {
                SettingsView()
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
                            print("Failed to toggle alarm notification: \(error)")
                        }
                    }
                }
            }
        }

        // FAB overlay
        GlassEffectContainer {
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
        guard !firingCoordinator.isFiring else { return }
        let now = Date()
        for alarm in alarms {
            let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
            guard isEnabled, alarm.nextFireDate <= now else { continue }
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
            set: { enabledStates[alarm.id] = $0 }
        )
    }

    private func alarmRow(_ alarm: Alarm) -> some View {
        GlassEffectContainer {
            AlarmCard(
                alarm: alarm,
                visualState: visualState(for: alarm),
                isEnabled: enabledBinding(for: alarm)
            )
        }
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
                        .font(TypographyTokens.labelSmall)
                }
                Text(label)
                    .font(TypographyTokens.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : ColorTokens.textSecondary)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .glassEffect(
                isSelected
                    ? GlassTokens.element.tint(color).interactive()
                    : GlassTokens.element,
                in: .capsule
            )
        }
    }

    private var filteredAlarms: [Alarm] {
        guard let filter = selectedCategoryFilter else { return alarms }
        return alarms.filter { $0.alarmCategory == filter }
    }

    private var activeCategories: [AlarmCategory] {
        let cats = Set(alarms.compactMap(\.alarmCategory))
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

    private func refreshNextFireDates() {
        let calculator = DateCalculator()
        let now = Date()
        for alarm in alarms where alarm.isEnabled {
            let correct = calculator.calculateNextFireDate(for: alarm, from: now)
            if alarm.nextFireDate != correct {
                alarm.nextFireDate = correct
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
