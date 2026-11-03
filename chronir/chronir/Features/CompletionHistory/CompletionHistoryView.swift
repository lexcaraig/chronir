import SwiftUI
import SwiftData

struct CompletionHistoryView: View {
    let alarmID: UUID?
    let alarmTitle: String?

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CompletionHistoryViewModel
    @State private var showPaywall = false

    init(alarmID: UUID? = nil, alarmTitle: String? = nil) {
        self.alarmID = alarmID
        self.alarmTitle = alarmTitle
        self._viewModel = State(initialValue: CompletionHistoryViewModel(alarmID: alarmID))
    }

    private var isPlusOrHigher: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    var body: some View {
        Group {
            if !isPlusOrHigher {
                upgradePrompt
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.groupedLogs.isEmpty {
                emptyState
            } else {
                logList
            }
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle(alarmTitle ?? "Completion History")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            if isPlusOrHigher {
                viewModel.loadLogs(context: modelContext)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(highlight: .history)
        }
        .onChange(of: SubscriptionService.shared.currentTier) {
            if isPlusOrHigher {
                viewModel.loadLogs(context: modelContext)
            }
        }
    }

    private var upgradePrompt: some View {
        VStack(spacing: SpacingTokens.lg) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(ColorTokens.textSecondary)
                .accessibilityHidden(true)
            // Copy comes from PlusFeature so the upsell can't drift from the paywall.
            ChronirText(
                PlusFeature.history.title,
                style: .headlineMedium,
                alignment: .center
            )
            ChronirText(
                PlusFeature.history.benefit,
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            // Same presentation as every other paywall entry point (full-screen cover).
            ChronirButton("Upgrade to Plus", style: .primary) {
                showPaywall = true
            }
            .padding(.horizontal, SpacingTokens.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Completions Yet",
            systemImage: "clock.badge.checkmark",
            description: Text("Completions will appear here after your alarms fire.")
        )
    }

    private var logList: some View {
        List {
            if alarmID != nil {
                streakSection
            }
            ForEach(viewModel.groupedLogs, id: \.date) { group in
                Section {
                    ForEach(group.logs) { log in
                        CompletionLogRow(
                            log: log,
                            alarmTitle: alarmID == nil ? log.alarm?.title : nil
                        )
                    }
                } header: {
                    ChronirText(group.date, style: .labelLarge, color: ColorTokens.textSecondary)
                }
                .listRowBackground(ColorTokens.surfaceCard)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var streakSection: some View {
        let current = StreakCalculator.currentStreak(from: viewModel.logs)
        let longest = StreakCalculator.longestStreak(from: viewModel.logs)
        return Section {
            HStack(alignment: .top) {
                streakColumn("Current Streak", value: current, alignment: .leading)
                Spacer()
                streakColumn("Longest Streak", value: longest, alignment: .trailing)
            }
        } header: {
            ChronirText("Streaks", style: .labelLarge, color: ColorTokens.textSecondary)
        } footer: {
            ChronirText(
                "Occurrences marked done in a row. A skip doesn't break a streak; a snooze does.",
                style: .bodySmall,
                color: ColorTokens.textSecondary
            )
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private func streakColumn(_ title: String, value: Int, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: SpacingTokens.xxs) {
            ChronirText(title, style: .labelMedium, color: ColorTokens.textSecondary)
            ChronirText("\(value)", style: .headlineLarge)
            ChronirText("done in a row", style: .bodySmall, color: ColorTokens.textSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value) done in a row")
    }
}

#Preview("Light") {
    NavigationStack {
        CompletionHistoryView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        CompletionHistoryView()
    }
    .preferredColorScheme(.dark)
}
