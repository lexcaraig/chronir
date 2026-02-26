import SwiftUI
import SwiftData
import AlarmKit
#if canImport(UIKit)
import UIKit
#endif

struct AlarmFiringView: View {
    let alarmID: UUID
    @Environment(\.modelContext) private var modelContext
    private let settings = UserSettings.shared
    @State private var viewModel = AlarmFiringViewModel()
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var holdTask: Task<Void, Never>?
    @State private var cachedPhoto: UIImage?
    @State private var showCustomSnoozePicker = false
    @State private var isReady = false

    private let holdDuration: TimeInterval = 3.0

    var body: some View {
        FullScreenAlarmTemplate {
            if isReady, let alarm = viewModel.alarm {
                content(for: alarm)
            } else {
                // Show blank firing background until we confirm the alarm is still alerting.
                // Prevents a visible flash of the firing UI when returning from a lock screen stop.
                Color.clear
            }
        }
        .sheet(isPresented: $showCustomSnoozePicker) {
            CustomSnoozePickerView { duration in
                Task { await viewModel.snooze(interval: .custom(duration)) }
            }
        }
        .onDisappear {
            viewModel.stopFiring()
            Task { await viewModel.completeIfNeeded() }
        }
        .task {
            viewModel.modelContext = modelContext
            loadAlarmFromContext()
            if viewModel.alarm == nil {
                await viewModel.loadAlarm(id: alarmID)
                #if os(iOS)
                if let alarm = viewModel.alarm, alarm.photoFileName != nil {
                    cachedPhoto = PhotoStorageService.loadPhoto(for: alarm.id)
                }
                #endif
            }
            if viewModel.alarm != nil {
                let akAlarms = (try? AlarmManager.shared.alarms) ?? []
                let isAlerting = akAlarms.contains { $0.id == alarmID && $0.state == .alerting }
                if isAlerting {
                    // Normal firing — AlarmKit confirms alarm is active
                    isReady = true
                    AlarmFiringCoordinator.shared.stoppedForCustomSound.insert(alarmID)
                    viewModel.startFiring()
                } else if AlarmFiringCoordinator.shared.stoppedForCustomSound.contains(alarmID)
                            || AlarmFiringCoordinator.shared.presentingPastDue.contains(alarmID) {
                    // Past-due re-presentation (flags set before presentAlarm call)
                    isReady = true
                    viewModel.startFiring()
                } else {
                    // Alarm was already handled on lock screen — complete and dismiss
                    await viewModel.completeIfNeeded()
                    AlarmFiringCoordinator.shared.dismissFiring()
                }
            }
        }
    }

    private func loadAlarmFromContext() {
        let targetID = alarmID
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.id == targetID }
        )
        if let alarm = try? modelContext.fetch(descriptor).first {
            viewModel.alarm = alarm
            #if os(iOS)
            if alarm.photoFileName != nil {
                cachedPhoto = PhotoStorageService.loadPhoto(for: alarm.id)
            }
            #endif
        }
    }

    @ViewBuilder
    private func content(for alarm: Alarm) -> some View {
        VStack(spacing: SpacingTokens.xxxl) {
            ScrollView {
                VStack(spacing: SpacingTokens.xxxl) {
                    Spacer(minLength: SpacingTokens.xxxl)

                    ChronirText(alarm.title, style: .headlineLarge, color: ColorTokens.firingForeground)

                    ChronirText(
                        alarm.nextFireDate.formatted(date: .omitted, time: .shortened),
                        style: .displayAlarm,
                        color: ColorTokens.firingForeground,
                        maxLines: 1,
                        minimumScaleFactor: 0.5
                    )

                    ChronirBadge(cycleType: alarm.cycleType)

                    #if os(iOS)
                    if let photo = cachedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 280, maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
                    }
                    #endif

                    if let note = alarm.note, !note.isEmpty {
                        ChronirText(note, style: .bodySecondary, color: ColorTokens.firingForeground.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpacingTokens.lg)
                    }

                    if alarm.snoozeCount > 0 {
                        ChronirText(
                            "Snoozed \(alarm.snoozeCount) time\(alarm.snoozeCount == 1 ? "" : "s")",
                            style: .bodySecondary,
                            color: ColorTokens.warning
                        )
                    }

                    Spacer(minLength: SpacingTokens.xxxl)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)

            if settings.snoozeEnabled {
                SnoozeOptionBar(
                    onSnooze: { interval in
                        Task { await viewModel.snooze(interval: interval) }
                    },
                    showCustomButton: SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank,
                    onCustomTap: { showCustomSnoozePicker = true }
                )
            }

            if alarm.cycleType != .oneTime {
                Button {
                    Task { await viewModel.skip() }
                } label: {
                    HStack(spacing: SpacingTokens.xs) {
                        Image(systemName: "forward.end")
                        Text("Skip This Occurrence")
                    }
                    .foregroundStyle(ColorTokens.firingForeground.opacity(0.7))
                    .chronirFont(.bodyMedium)
                }
            }

            dismissButton

            Spacer(minLength: SpacingTokens.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.firingBackground)
    }

    private var isPlusUser: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    @ViewBuilder
    private var dismissButton: some View {
        if isPlusUser {
            // Plus tier: "Mark as Done" (primary) + "Stop Alarm" / "Hold to Stop" (secondary)
            VStack(spacing: SpacingTokens.sm) {
                ChronirButton("Mark as Done", style: .primary) {
                    Task { await viewModel.dismiss() }
                }
                .padding(.horizontal, SpacingTokens.xxxl)

                if settings.slideToStopEnabled {
                    holdButton(label: "Hold to Stop", holdLabel: "Keep holding...") {
                        Task { await viewModel.stop() }
                    }
                } else {
                    Button {
                        Task { await viewModel.stop() }
                    } label: {
                        ChronirText(
                            "Stop Alarm",
                            style: .bodyMedium,
                            color: ColorTokens.firingForeground.opacity(0.7)
                        )
                    }
                }
            }
        } else {
            // Free tier: single dismiss action (unchanged)
            if settings.slideToStopEnabled {
                holdButton(label: "Hold to Dismiss", holdLabel: "Keep holding...") {
                    Task { await viewModel.dismiss() }
                }
            } else {
                ChronirButton("Mark as Done", style: .primary) {
                    Task { await viewModel.dismiss() }
                }
                .padding(.horizontal, SpacingTokens.xxxl)
            }
        }
    }

    private func holdButton(label: String, holdLabel: String, action: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: RadiusTokens.lg)
                .fill(ColorTokens.backgroundTertiary)
                .frame(height: 56)

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: RadiusTokens.lg)
                    .fill(ColorTokens.primary.opacity(0.6))
                    .frame(width: geo.size.width * holdProgress, height: 56)
            }
            .frame(height: 56)

            ChronirText(
                isHolding ? holdLabel : label,
                style: .headlineSmall,
                color: ColorTokens.firingForeground
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.lg))
        .padding(.horizontal, SpacingTokens.xxxl)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in startHold(action: action) }
                .onEnded { _ in cancelHold() }
        )
    }

    private func startHold(action: @escaping () -> Void) {
        guard !isHolding else { return }
        isHolding = true
        withAnimation(.linear(duration: holdDuration)) {
            holdProgress = 1.0
        }
        holdTask = Task {
            try? await Task.sleep(for: .seconds(holdDuration))
            guard !Task.isCancelled else { return }
            completeHold(action: action)
        }
    }

    private func completeHold(action: @escaping () -> Void) {
        holdTask?.cancel()
        holdTask = nil
        isHolding = false
        holdProgress = 0
        action()
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil
        isHolding = false
        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
        }
    }
}

#Preview("Swipe Dismiss") {
    AlarmFiringView(alarmID: UUID())
}
