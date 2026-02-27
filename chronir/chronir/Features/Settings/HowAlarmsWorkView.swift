import SwiftUI

struct HowAlarmsWorkView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    ChronirText(
                        "Chronir uses Apple's AlarmKit to schedule alarms that break through Do Not Disturb and Focus modes — just like the built-in Clock app.",
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
            } header: {
                ChronirText("How It Works", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    bulletRow("Alarm title, category, and notes")
                    bulletRow("Alarm sound selection")
                    bulletRow("Snooze duration (in-app)")
                    bulletRow("Require Dismissal for critical alarms")
                    bulletRow("Pre-alarm warning notifications")
                    bulletRow("Repeat schedule and interval")
                }
            } header: {
                ChronirText("What You Control", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    bulletRow("Lock screen dismiss gesture (slide to stop)")
                    bulletRow("Lock screen auto-silence (~1 minute)")
                    bulletRow("Notification title truncation (~32 characters)")
                    bulletRow("Lock screen snooze duration (fixed at 9 minutes)")
                }
            } header: {
                ChronirText("What iOS Controls", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    tipRow(
                        icon: "textformat.size",
                        text: "Keep alarm titles under 32 characters to avoid truncation on the lock screen"
                    )
                    tipRow(
                        icon: "lock.shield",
                        text: "Use Require Dismissal for critical alarms — the alarm will keep re-alerting after snooze until you manually stop it"
                    )
                    tipRow(
                        icon: "bell.badge",
                        text: "Enable pre-alarm warnings to get a heads-up notification before important alarms"
                    )
                }
            } header: {
                ChronirText("Tips", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("How Alarms Work")
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: SpacingTokens.xs) {
            ChronirText("\u{2022}", style: .bodySecondary, color: ColorTokens.textSecondary)
            ChronirText(text, style: .bodySecondary, color: ColorTokens.textSecondary)
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: SpacingTokens.sm) {
            ChronirIcon(systemName: icon, size: .small, color: ColorTokens.primary)
            ChronirText(text, style: .bodySecondary, color: ColorTokens.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        HowAlarmsWorkView()
    }
}
