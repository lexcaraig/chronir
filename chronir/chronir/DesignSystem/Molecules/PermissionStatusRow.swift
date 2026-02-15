import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PermissionStatusRow: View {
    let label: String
    let status: PermissionStatus

    var body: some View {
        HStack {
            ChronirText(label, style: .bodyPrimary)
            Spacer()
            statusBadge
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if status == .denied {
                openSettings()
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .authorized:
            ChronirBadge("Enabled", color: ColorTokens.badgeSuccess)
        case .denied:
            HStack(spacing: SpacingTokens.xs) {
                ChronirBadge("Denied", color: ColorTokens.badgeError)
                ChronirIcon(
                    systemName: "arrow.up.forward.app",
                    size: .small,
                    color: ColorTokens.textSecondary
                )
            }
        case .provisional:
            ChronirBadge("Provisional", color: ColorTokens.badgeWarning)
        case .notDetermined:
            ChronirBadge("Not Set", color: ColorTokens.textSecondary)
        }
    }

    private func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}

#Preview("Permission States") {
    List {
        PermissionStatusRow(label: "Notifications", status: .authorized)
        PermissionStatusRow(label: "Notifications", status: .denied)
        PermissionStatusRow(label: "Notifications", status: .provisional)
        PermissionStatusRow(label: "Notifications", status: .notDetermined)
    }
    .scrollContentBackground(.hidden)
    .background(ColorTokens.backgroundPrimary)
}
