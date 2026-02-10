import SwiftUI
import SwiftData

struct AlarmFiringView: View {
    let alarmID: UUID
    @Environment(\.modelContext) private var modelContext
    private let settings = UserSettings.shared
    @State private var viewModel = AlarmFiringViewModel()
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false

    private let holdDuration: TimeInterval = 3.0

    var body: some View {
        FullScreenAlarmTemplate {
            if let alarm = viewModel.alarm {
                content(for: alarm)
            } else {
                ProgressView()
                    .tint(ColorTokens.firingForeground)
            }
        }
        .task {
            loadAlarmFromContext()
            if viewModel.alarm == nil {
                await viewModel.loadAlarm(id: alarmID)
            }
            if viewModel.alarm != nil {
                viewModel.startFiring()
            }
        }
    }

    private func loadAlarmFromContext() {
        let targetID = alarmID
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.id == targetID }
        )
        viewModel.alarm = try? modelContext.fetch(descriptor).first
    }

    @ViewBuilder
    private func content(for alarm: Alarm) -> some View {
        VStack(spacing: SpacingTokens.xxxl) {
            Spacer()

            ChronirText(alarm.title, style: .headlineLarge, color: ColorTokens.firingForeground)

            ChronirText(
                alarm.scheduledTime.formatted(date: .omitted, time: .shortened),
                style: .displayAlarm,
                color: ColorTokens.firingForeground
            )

            ChronirBadge(cycleType: alarm.cycleType)

            if let photo = PhotoStorageService.loadPhoto(for: alarm.id) {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
                    .padding(.horizontal, SpacingTokens.lg)
            }

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

            Spacer()

            if settings.snoozeEnabled {
                SnoozeOptionBar { interval in
                    Task { await viewModel.snooze(interval: interval) }
                }
            }

            dismissButton

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.firingBackground)
    }

    @ViewBuilder
    private var dismissButton: some View {
        if settings.slideToStopEnabled {
            holdToDismissButton
        } else {
            ChronirButton("Mark as Done", style: .primary) {
                Task { await viewModel.dismiss() }
            }
            .padding(.horizontal, SpacingTokens.xxxl)
        }
    }

    private var holdToDismissButton: some View {
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
                isHolding ? "Keep holding..." : "Hold to Dismiss",
                style: .headlineSmall,
                color: ColorTokens.firingForeground
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.lg))
        .padding(.horizontal, SpacingTokens.xxxl)
        .gesture(
            LongPressGesture(minimumDuration: holdDuration)
                .onChanged { _ in
                    startHold()
                }
                .onEnded { _ in
                    completeHold()
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    cancelHold()
                }
        )
    }

    private func startHold() {
        guard !isHolding else { return }
        isHolding = true
        withAnimation(.linear(duration: holdDuration)) {
            holdProgress = 1.0
        }
    }

    private func completeHold() {
        isHolding = false
        holdProgress = 0
        Task { await viewModel.dismiss() }
    }

    private func cancelHold() {
        guard isHolding else { return }
        isHolding = false
        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
        }
    }
}

#Preview("Swipe Dismiss") {
    AlarmFiringView(alarmID: UUID())
}
