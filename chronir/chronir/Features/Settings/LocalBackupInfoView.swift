import SwiftUI

struct LocalBackupInfoView: View {
    @State private var showPaywall = false

    var body: some View {
        List {
            Section {
                ChronirText(
                    backupDescription,
                    style: .bodySecondary,
                    color: ColorTokens.textSecondary
                )
            } header: {
                Text("How It Works")
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                comparisonRow(
                    tier: "Free",
                    detail: "Stored on this iPhone only. Included in your iCloud device backup.",
                    badge: ColorTokens.textSecondary
                )
                comparisonRow(
                    tier: "Plus",
                    detail: PlusFeature.cloudBackup.benefit
                        + " Sign in to back up and sync your alarms to the cloud.",
                    badge: ColorTokens.primary
                )
            } header: {
                Text("Free vs Plus")
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                Button { showPaywall = true } label: {
                    Label {
                        ChronirText("Upgrade to Plus", style: .bodyPrimary, color: ColorTokens.primary)
                    } icon: {
                        Image(systemName: PlusFeature.cloudBackup.iconName)
                            .foregroundStyle(ColorTokens.primary)
                    }
                }
            }
            .listRowBackground(ColorTokens.surfaceCard)

            Section {
                tipRow(
                    icon: "icloud",
                    text: "Enable iCloud Backup in Settings > Apple ID > iCloud."
                )
                tipRow(
                    icon: "arrow.clockwise",
                    text: "Backups happen automatically when your iPhone is locked, charging, and on Wi-Fi."
                )
            } header: {
                Text("Tips")
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Backup & Sync")
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(highlight: .cloudBackup)
        }
    }

    // swiftlint:disable:next line_length
    private let backupDescription = "Your alarms are stored on this device. If you back up your iPhone to iCloud, your alarm data is included automatically."

    private func comparisonRow(tier: String, detail: String, badge: Color) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirBadge(tier, color: badge)
            ChronirText(detail, style: .bodySecondary, color: ColorTokens.textSecondary)
        }
        .padding(.vertical, SpacingTokens.xxs)
        .accessibilityElement(children: .combine)
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: SpacingTokens.sm) {
            ChronirIcon(systemName: icon, size: .small, color: ColorTokens.primary)
                .accessibilityHidden(true)
            ChronirText(text, style: .bodySecondary, color: ColorTokens.textSecondary)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        LocalBackupInfoView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        LocalBackupInfoView()
    }
    .preferredColorScheme(.dark)
}
