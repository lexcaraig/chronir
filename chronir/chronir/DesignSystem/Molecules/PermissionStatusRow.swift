import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PermissionStatusRow: View {
    let label: String
    let status: PermissionStatus

    var body: some View {
        if status == .denied {
            // Only the denied state is actionable — make it a real button so VoiceOver says so.
            Button(action: openSettings) { row }
                .buttonStyle(.plain)
                .accessibilityHint("Opens Settings to allow \(label)")
        } else {
            row
        }
    }

    private var row: some View {
        HStack {
            ChronirText(label, style: .bodyPrimary)
            Spacer()
            statusBadge
        }
        .frame(minHeight: SpacingTokens.touchMinTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .authorized:
            ChronirBadge(
                "Enabled",
                color: ColorTokens.badgeSuccessBackground,
                foreground: ColorTokens.badgeSuccessForeground
            )
        case .denied:
            HStack(spacing: SpacingTokens.xs) {
                ChronirBadge(
                    "Denied",
                    color: ColorTokens.badgeErrorBackground,
                    foreground: ColorTokens.badgeErrorForeground
                )
                ChronirIcon(
                    systemName: "arrow.up.forward.app",
                    size: .small,
                    color: ColorTokens.textSecondary
                )
                .accessibilityHidden(true)
            }
        case .provisional:
            ChronirBadge(
                "Provisional",
                color: ColorTokens.badgeWarningBackground,
                foreground: ColorTokens.badgeWarningForeground
            )
        case .notDetermined:
            ChronirBadge(
                "Not Set",
                color: ColorTokens.badgeNeutralBackground,
                foreground: ColorTokens.badgeNeutralForeground
            )
        }
    }

    private func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}

private struct PermissionStatesPreview: View {
    var body: some View {
        List {
            PermissionStatusRow(label: "Notifications", status: .authorized)
            PermissionStatusRow(label: "Notifications", status: .denied)
            PermissionStatusRow(label: "Notifications", status: .provisional)
            PermissionStatusRow(label: "Notifications", status: .notDetermined)
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview("Light") {
    PermissionStatesPreview()
}

#Preview("Dark") {
    PermissionStatesPreview()
        .environment(\.colorScheme, .dark)
}
