import SwiftUI
import SwiftData

// Shared by AlarmListView and CategoryDetailView so an alarm row taps, toggles, swipes,
// reads to VoiceOver and gates the Free-tier limit the same way wherever it appears.

// MARK: - Row actions

@MainActor
enum AlarmRowActions {
    /// Free tier: enabling is blocked once the limit of enabled alarms is reached.
    /// Disabling, opening, editing and deleting are never gated.
    static func canEnable(_ alarm: Alarm, among alarms: [Alarm]) -> Bool {
        guard !alarm.isEnabled, let limit = SubscriptionService.shared.currentTier.alarmLimit else { return true }
        return alarms.filter(\.isEnabled).count < limit
    }

    /// Applies one toggle change: persists it, then registers or cancels with AlarmKit.
    static func setEnabled(_ alarm: Alarm, _ isEnabled: Bool) {
        guard alarm.isEnabled != isEnabled else { return }
        alarm.isEnabled = isEnabled
        alarm.updatedAt = Date()
        if !isEnabled && alarm.isPendingConfirmation {
            PendingConfirmationService.shared.cancelPending(alarm: alarm)
        }
        if isEnabled && alarm.nextFireDate < Date() {
            alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        }
        Task {
            if isEnabled {
                let scheduled = await AlarmSchedulingStatus.shared.schedule(alarm)
                if !scheduled && UserSettings.shared.hapticsEnabled { HapticService.shared.playError() }
            } else {
                do {
                    try await AlarmScheduler.shared.cancelAlarm(alarm)
                } catch {
                    AnalyticsService.shared.recordError(error, context: "cancel_alarm_toggle")
                }
                AlarmSchedulingStatus.shared.clear(alarm.id)
            }
            await CloudSyncService.shared.pushAlarmModel(alarm)
        }
    }

    /// Toggle binding: the Free-tier limit gates turning an alarm on, nothing else.
    static func enabledBinding(
        for alarm: Alarm,
        among alarms: @escaping @autoclosure () -> [Alarm],
        onLimitReached: @escaping () -> Void
    ) -> Binding<Bool> {
        Binding(
            get: { alarm.isEnabled },
            set: { newValue in
                if newValue && !canEnable(alarm, among: alarms()) {
                    onLimitReached()
                } else {
                    setEnabled(alarm, newValue)
                    if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
                }
            }
        )
    }

    /// The date an alarm moves to if the current occurrence is skipped.
    static func nextDateAfterSkip(_ alarm: Alarm) -> Date {
        DateCalculator().calculateNextFireDate(for: alarm, from: alarm.nextFireDate)
    }

    static func skip(_ alarm: Alarm, context: ModelContext) {
        let log = CompletionLog(
            alarmID: alarm.id,
            scheduledDate: alarm.nextFireDate,
            completedAt: Date(),
            action: .skipped,
            snoozeCount: alarm.snoozeCount
        )
        log.alarm = alarm
        context.insert(log)

        alarm.snoozeCount = 0
        alarm.nextFireDate = nextDateAfterSkip(alarm)
        try? context.save()

        Task {
            await AlarmSchedulingStatus.shared.reschedule(alarm)
            await CloudSyncService.shared.pushAlarmModel(alarm)
        }
        if UserSettings.shared.hapticsEnabled { HapticService.shared.playSelection() }
    }

    static func confirmPending(_ alarm: Alarm, context: ModelContext) {
        NotificationService.shared.removeDeliveredNotifications(for: alarm.id)
        PendingConfirmationService.shared.confirmDone(alarm: alarm)
        alarm.updatedAt = Date()
        try? context.save()
        Task { await CloudSyncService.shared.pushAlarmModel(alarm) }
        if UserSettings.shared.hapticsEnabled { HapticService.shared.playSuccess() }
    }

    static func delete(_ alarm: Alarm, context: ModelContext) {
        let alarmID = alarm.id
        Task {
            try? await AlarmScheduler.shared.cancelAlarm(alarm)
        }
        AlarmSchedulingStatus.shared.clear(alarmID)
        PhotoStorageService.deletePhoto(for: alarmID)
        NotificationService.shared.removeDeliveredNotifications(for: alarmID)
        context.delete(alarm)
        try? context.save()
        Task { try? await CloudSyncService.shared.deleteRemoteAlarm(id: alarmID.uuidString) }
    }

    /// Current streak per alarm, computed once per list render instead of once per row.
    static func streaks(from logs: [CompletionLog]) -> [UUID: Int] {
        Dictionary(grouping: logs, by: \.alarmID).mapValues(StreakCalculator.currentStreak(from:))
    }
}

// MARK: - Row view

struct AlarmListRow: View {
    let alarm: Alarm
    @Binding var isEnabled: Bool
    var streak: Int = 0
    var isPlusUser: Bool = false
    var isUnscheduled: Bool = false
    let onOpen: () -> Void
    let onDelete: () -> Void
    let onSkip: () -> Void
    let onConfirmDone: () -> Void

    private var visualState: AlarmVisualState {
        if !alarm.isEnabled { return .inactive }
        if alarm.isPendingConfirmation { return .pending }
        if alarm.snoozeCount > 0 { return .snoozed }
        return .active
    }

    var body: some View {
        AdaptiveGlassContainer {
            AlarmCard(
                alarm: alarm,
                visualState: visualState,
                isEnabled: $isEnabled,
                streak: streak,
                isPlusUser: isPlusUser
            )
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isEnabled ? "On" : "Off")
        .accessibilityHint("Opens the alarm to edit")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, onOpen)
        .accessibilityAction(named: isEnabled ? "Turn Off" : "Turn On") { isEnabled.toggle() }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(
            top: SpacingTokens.xxs, leading: SpacingTokens.md,
            bottom: SpacingTokens.xxs, trailing: SpacingTokens.md
        ))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: onOpen) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(ColorTokens.swipeEdit)
            if alarm.cycleType != .oneTime && alarm.isEnabled {
                Button(action: onSkip) {
                    Label("Skip", systemImage: "forward.end")
                }
                .tint(ColorTokens.swipeSkip)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if alarm.isPendingConfirmation {
                Button(action: onConfirmDone) {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
                .tint(ColorTokens.swipeConfirm)
            }
            Button {
                isEnabled.toggle()
            } label: {
                Label(isEnabled ? "Disable" : "Enable", systemImage: isEnabled ? "bell.slash" : "bell")
            }
            .tint(isEnabled ? ColorTokens.swipeNeutral : ColorTokens.swipeConfirm)
        }
    }

    private var accessibilityLabel: String {
        var parts = [alarm.title, alarm.schedule.displayName]
        if let category = alarm.alarmCategory { parts.append(category.displayName) }
        if let badge = visualState.statusBadge { parts.append(badge.text) }
        if isUnscheduled { parts.append("Not scheduled, won't ring") }
        if visualState == .inactive {
            parts.append(alarm.scheduledTime.formatted(date: .omitted, time: .shortened))
        } else {
            parts.append("Next \(alarm.nextFireDate.formatted(date: .abbreviated, time: .shortened))")
        }
        if isPlusUser && streak >= 2 { parts.append("\(streak) completions in a row") }
        if alarm.isPersistent { parts.append("Persistent") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Delete / skip confirmations

private struct AlarmRowConfirmations: ViewModifier {
    @Binding var alarmToDelete: Alarm?
    @Binding var alarmToSkip: Alarm?
    let context: ModelContext

    func body(content: Content) -> some View {
        content
            .alert(
                "Delete Alarm?",
                isPresented: isPresented($alarmToDelete),
                presenting: alarmToDelete
            ) { alarm in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    AlarmRowActions.delete(alarm, context: context)
                }
            } message: { alarm in
                Text("\"\(alarm.title)\" and its completion history will be deleted. This can't be undone.")
            }
            .confirmationDialog(
                alarmToSkip.map(skipTitle) ?? "",
                isPresented: isPresented($alarmToSkip),
                titleVisibility: .visible,
                presenting: alarmToSkip
            ) { alarm in
                Button("Skip This Occurrence") {
                    AlarmRowActions.skip(alarm, context: context)
                }
                Button("Keep", role: .cancel) {}
            } message: { _ in
                Text("The skipped occurrence is logged in the alarm's history.")
            }
    }

    private func skipTitle(_ alarm: Alarm) -> String {
        let next = AlarmRowActions.nextDateAfterSkip(alarm)
        return "Skip to \(next.formatted(date: .abbreviated, time: .shortened))?"
    }

    private func isPresented(_ item: Binding<Alarm?>) -> Binding<Bool> {
        Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
    }
}

extension View {
    func alarmRowConfirmations(
        alarmToDelete: Binding<Alarm?>,
        alarmToSkip: Binding<Alarm?>,
        context: ModelContext
    ) -> some View {
        modifier(AlarmRowConfirmations(alarmToDelete: alarmToDelete, alarmToSkip: alarmToSkip, context: context))
    }
}

#Preview("Light") {
    @Previewable @State var isEnabled = true
    List {
        AlarmListRow(
            alarm: Alarm(
                title: "Pay Rent",
                cycleType: .monthlyDate,
                schedule: .monthlyDate(daysOfMonth: [1], interval: 1)
            ),
            isEnabled: $isEnabled,
            streak: 3,
            isPlusUser: true,
            onOpen: {}, onDelete: {}, onSkip: {}, onConfirmDone: {}
        )
    }
    .listStyle(.plain)
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.light)
}

#Preview("Dark, not scheduled") {
    @Previewable @State var isEnabled = true
    List {
        AlarmListRow(
            alarm: Alarm(title: "Renew Passport", cycleType: .annual),
            isEnabled: $isEnabled,
            isUnscheduled: true,
            onOpen: {}, onDelete: {}, onSkip: {}, onConfirmDone: {}
        )
    }
    .listStyle(.plain)
    .modelContainer(for: Alarm.self, inMemory: true)
    .preferredColorScheme(.dark)
}
