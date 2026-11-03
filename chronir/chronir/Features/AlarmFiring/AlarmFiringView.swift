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
    @State private var cachedPhoto: UIImage?
    @State private var showCustomSnoozePicker = false
    @State private var showSkipConfirmation = false
    @State private var isReady = false

    private let holdDuration: TimeInterval = 3.0

    var body: some View {
        FullScreenAlarmTemplate {
            if isReady, let alarm = viewModel.alarm {
                content(for: alarm)
            } else {
                // Show the blank (always-dark) firing background until we confirm the alarm is still
                // alerting. Prevents a flash of the firing UI, or of a light background, when
                // returning from a lock screen stop.
                ColorTokens.firingBackground
                    .ignoresSafeArea()
            }
        }
        // The firing surface is always dark, whatever the app theme, so adaptive tokens inside shared
        // components (snooze tiles, badges) resolve to their dark values. Applied before `.sheet` so
        // the custom snooze sheet keeps the app's appearance.
        .environment(\.colorScheme, .dark)
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
            }
            if viewModel.alarm != nil {
                let akAlarms = (try? AlarmManager.shared.alarms) ?? []
                let isAlerting = AlarmScheduler.activeRegistration(for: alarmID, in: akAlarms)?.state == .alerting
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
            // Photo decode runs after firing has started so it never delays the alarm sound.
            #if os(iOS)
            if isReady, let alarm = viewModel.alarm, alarm.photoFileName != nil {
                cachedPhoto = await Self.loadDisplayPhoto(for: alarm.id)
            }
            #endif
        }
    }

    private func loadAlarmFromContext() {
        let targetID = alarmID
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.id == targetID }
        )
        if let alarm = try? modelContext.fetch(descriptor).first {
            viewModel.alarm = alarm
        }
    }

    /// Bounds of the firing-screen photo.
    private static let photoMaxSize = CGSize(
        width: SpacingTokens.firingPhotoMaxWidth, height: SpacingTokens.firingPhotoMaxHeight
    )

    #if os(iOS)
    /// Decodes the photo at display size (3x the frame) instead of full camera resolution.
    private static func loadDisplayPhoto(for id: UUID) async -> UIImage? {
        guard let photo = PhotoStorageService.loadPhoto(for: id) else { return nil }
        let target = photoMaxSize.width * 3
        let longest = max(photo.size.width, photo.size.height)
        guard longest > target else { return photo }
        let scale = target / longest
        let size = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
        return await photo.byPreparingThumbnail(ofSize: size) ?? photo
    }
    #endif

    @ViewBuilder
    private func content(for alarm: Alarm) -> some View {
        VStack(spacing: SpacingTokens.lg) {
            ScrollView {
                VStack(spacing: SpacingTokens.lg) {
                    Spacer(minLength: SpacingTokens.xxxl)

                    // What is due is the payload for a long-cycle obligation; the clock time is context.
                    ChronirText(
                        alarm.title,
                        style: .displaySmall,
                        color: ColorTokens.firingTextPrimary,
                        maxLines: 3,
                        alignment: .center,
                        minimumScaleFactor: 0.7
                    )
                    .padding(.horizontal, SpacingTokens.lg)
                    .accessibilityAddTraits(.isHeader)

                    ChronirText(
                        alarm.nextFireDate.formatted(date: .omitted, time: .shortened),
                        style: .headlineMedium,
                        color: ColorTokens.firingTextSecondary,
                        maxLines: 1
                    )

                    ChronirBadge(cycleType: alarm.cycleType)

                    if let lastDone = alarm.lastCompletedAt {
                        ChronirText(
                            "Last done \(lastDone.formatted(date: .abbreviated, time: .omitted))",
                            style: .bodyMedium,
                            color: ColorTokens.firingTextSecondary
                        )
                    }

                    #if os(iOS)
                    if let photo = cachedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: Self.photoMaxSize.width, maxHeight: Self.photoMaxSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
                            .accessibilityLabel("Alarm photo")
                    }
                    #endif

                    if let note = alarm.note, !note.isEmpty {
                        ChronirText(
                            note,
                            style: .bodySecondary,
                            color: ColorTokens.firingTextSecondary,
                            alignment: .center
                        )
                        .padding(.horizontal, SpacingTokens.lg)
                    }

                    if alarm.snoozeCount > 0 {
                        ChronirText(
                            "Snoozed \(alarm.snoozeCount) time\(alarm.snoozeCount == 1 ? "" : "s")",
                            style: .bodySecondary,
                            color: ColorTokens.firingWarning
                        )
                    }

                    Spacer(minLength: SpacingTokens.lg)
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
                    showSkipConfirmation = true
                } label: {
                    Label("Skip This Occurrence", systemImage: "forward.end")
                        .chronirFont(.bodyMedium)
                        .foregroundStyle(ColorTokens.firingTextSecondary)
                        .frame(minHeight: SpacingTokens.touchMinTarget)
                        .padding(.horizontal, SpacingTokens.md)
                        .contentShape(Rectangle())
                }
                .confirmationDialog(
                    skipConfirmationTitle(for: alarm),
                    isPresented: $showSkipConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Skip This Occurrence") {
                        Task { await viewModel.skip() }
                    }
                    Button("Keep Alarm", role: .cancel) {}
                } message: {
                    Text("The alarm stops now and the skip is logged in its history.")
                }
            }

            dismissButton(for: alarm)

            Spacer(minLength: SpacingTokens.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.firingBackground)
    }

    private func skipConfirmationTitle(for alarm: Alarm) -> String {
        let next = AlarmRowActions.nextDateAfterSkip(alarm)
        return "Skip to \(next.formatted(date: .abbreviated, time: .shortened))?"
    }

    private var isPlusUser: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    @ViewBuilder
    private func dismissButton(for alarm: Alarm) -> some View {
        if isPlusUser {
            // Plus tier: "Mark as Done" (primary) completes the occurrence. The secondary action only
            // silences it and asks again later (pending confirmation), so its copy says exactly that.
            let followUp = "Silences the alarm. Chronir asks again in \(alarm.followUpInterval.displayName)."
            VStack(spacing: SpacingTokens.sm) {
                firingPrimaryButton("Mark as Done") {
                    Task { await viewModel.dismiss() }
                }

                if settings.slideToStopEnabled {
                    holdButton(label: "Hold for Not Done Yet", accessibilityLabel: "Not done yet") {
                        Task { await viewModel.stop() }
                    }
                    .accessibilityHint(followUp)
                } else {
                    Button {
                        Task { await viewModel.stop() }
                    } label: {
                        VStack(spacing: SpacingTokens.xxs) {
                            ChronirText("Not Done Yet", style: .titleSmall, color: ColorTokens.firingTextPrimary)
                            ChronirText(
                                followUp,
                                style: .bodySmall,
                                color: ColorTokens.firingTextSecondary,
                                alignment: .center
                            )
                        }
                        .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget)
                        .padding(.horizontal, SpacingTokens.xxxl)
                        .contentShape(Rectangle())
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        } else {
            // Free tier: single dismiss action
            if settings.slideToStopEnabled {
                holdButton(label: "Hold to Dismiss", accessibilityLabel: "Mark as done") {
                    Task { await viewModel.dismiss() }
                }
            } else {
                firingPrimaryButton("Mark as Done") {
                    Task { await viewModel.dismiss() }
                }
            }
        }
    }

    /// Primary action on the always-dark firing surface (static firing tokens, not the adaptive
    /// `primary`, so contrast holds in every app theme).
    private func firingPrimaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ChronirText(title, style: .titleMedium, color: ColorTokens.firingOnPrimary)
                .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget)
                .padding(.vertical, SpacingTokens.xs)
                .background(ColorTokens.firingPrimaryFill, in: RoundedRectangle(cornerRadius: RadiusTokens.lg))
        }
        .padding(.horizontal, SpacingTokens.xxxl)
    }
}

// MARK: - Hold to stop

extension AlarmFiringView {
    private func holdButton(
        label: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: RadiusTokens.lg)
                .fill(isHolding ? ColorTokens.firingControlFillPressed : ColorTokens.firingControlFill)

            GeometryReader { geo in
                // 0.35 keeps firingOnControl text above 4.5:1 where the progress fill sits behind it.
                RoundedRectangle(cornerRadius: RadiusTokens.lg)
                    .fill(ColorTokens.firingControlProgress.opacity(0.35))
                    .frame(width: geo.size.width * holdProgress)
            }

            ChronirText(
                isHolding ? "Keep holding..." : label,
                style: .headlineSmall,
                color: ColorTokens.firingOnControl
            )
            .padding(.vertical, SpacingTokens.sm)
        }
        .frame(minHeight: SpacingTokens.touchMinTarget + SpacingTokens.sm)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.lg))
        .contentShape(RoundedRectangle(cornerRadius: RadiusTokens.lg))
        .padding(.horizontal, SpacingTokens.xxxl)
        // The long press cancels on its own when the finger lifts early or slides off the bar.
        .onLongPressGesture(minimumDuration: holdDuration, maximumDistance: SpacingTokens.xxl) {
            completeHold(action: action)
        } onPressingChanged: { pressing in
            if pressing {
                startHold()
            } else if isHolding {
                cancelHold()
            }
        }
        // VoiceOver / Switch Control: a deliberate activation is intent enough, no hold required.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { action() }
    }

    private func startHold() {
        guard !isHolding else { return }
        isHolding = true
        if settings.hapticsEnabled {
            HapticService.shared.playImpact(style: .light)
        }
        withAnimation(.linear(duration: holdDuration)) {
            holdProgress = 1.0
        }
    }

    private func completeHold(action: @escaping () -> Void) {
        isHolding = false
        holdProgress = 0
        action()
    }

    private func cancelHold() {
        isHolding = false
        withAnimation(AnimationTokens.fast) {
            holdProgress = 0
        }
    }
}

#Preview("Light app theme") {
    AlarmFiringView(alarmID: UUID())
        .preferredColorScheme(.light)
}

#Preview("Dark app theme") {
    AlarmFiringView(alarmID: UUID())
        .preferredColorScheme(.dark)
}
