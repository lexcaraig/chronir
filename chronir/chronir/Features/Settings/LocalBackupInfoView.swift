import SwiftUI

struct LocalBackupInfoView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    ChronirText(
                        backupDescription,
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
            } header: {
                ChronirText("How It Works", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                comparisonRow(
                    tier: "Free",
                    detail: "Local storage only. Backed up via iCloud device backup.",
                    badge: ColorTokens.textSecondary
                )
                // TODO: Update when cloud backup is built (Sprint 10+)
                comparisonRow(
                    tier: "Plus",
                    detail: "Unlimited alarms, custom snooze, pre-alarm warnings, photo attachments, and completion history.",
                    badge: ColorTokens.primary
                )
            } header: {
                ChronirText("Free vs Plus", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    tipRow(
                        icon: "icloud",
                        text: "Enable iCloud Backup in Settings > Apple ID > iCloud"
                    )
                    tipRow(
                        icon: "arrow.clockwise",
                        text: "Backups happen automatically when locked, charging, and on Wi-Fi"
                    )
                }
            } header: {
                ChronirText("Tips", style: .labelLarge, color: ColorTokens.textSecondary)
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Backup & Sync")
    }

    // swiftlint:disable:next line_length
    private let backupDescription = "Your alarms are stored on this device. If you back up your iPhone to iCloud, your alarm data is included automatically."

    private func comparisonRow(tier: String, detail: String, badge: Color) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirBadge(tier, color: badge)
            ChronirText(detail, style: .bodySecondary, color: ColorTokens.textSecondary)
        }
        .padding(.vertical, SpacingTokens.xxs)
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
        LocalBackupInfoView()
    }
}
