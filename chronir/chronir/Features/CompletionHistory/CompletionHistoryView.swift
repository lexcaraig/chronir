import SwiftUI
import SwiftData

struct CompletionHistoryView: View {
    let alarmID: UUID?
    let alarmTitle: String?

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CompletionHistoryViewModel

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
        .onChange(of: SubscriptionService.shared.currentTier) {
            if isPlusOrHigher {
                viewModel.loadLogs(context: modelContext)
            }
        }
    }

    private var upgradePrompt: some View {
        VStack(spacing: SpacingTokens.lg) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(ColorTokens.textSecondary)
            ChronirText(
                "Completion History",
                style: .headlineMedium
            )
            ChronirText(
                "Upgrade to Plus to track your alarm completions, view streaks, and build consistency.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary
            )
            .multilineTextAlignment(.center)
            NavigationLink(destination: PaywallView()) {
                ChronirText("Upgrade to Plus", style: .headlineSmall, color: .white)
                    .frame(maxWidth: .infinity)
                    .padding(SpacingTokens.md)
                    .background(ColorTokens.primary)
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
            }
            .padding(.horizontal, SpacingTokens.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: SpacingTokens.lg) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 48))
                .foregroundStyle(ColorTokens.textSecondary)
            ChronirText(
                "No completion history yet",
                style: .bodySecondary,
                color: ColorTokens.textSecondary
            )
            ChronirText(
                "Completions will appear here after your alarms fire.",
                style: .caption,
                color: ColorTokens.textSecondary
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
        Section {
            HStack {
                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    ChronirText("Current Streak", style: .labelMedium, color: ColorTokens.textSecondary)
                    ChronirText(
                        "\(StreakCalculator.currentStreak(from: viewModel.logs))",
                        style: .headlineLarge
                    )
                }
                Spacer()
                VStack(alignment: .trailing, spacing: SpacingTokens.xxs) {
                    ChronirText("Longest Streak", style: .labelMedium, color: ColorTokens.textSecondary)
                    ChronirText(
                        "\(StreakCalculator.longestStreak(from: viewModel.logs))",
                        style: .headlineLarge
                    )
                }
            }
        } header: {
            ChronirText("Streaks", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }
}

#Preview {
    NavigationStack {
        CompletionHistoryView()
    }
}
