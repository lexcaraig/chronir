import SwiftUI

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: SpacingTokens.lg) {
                Spacer()
                    .frame(minHeight: SpacingTokens.md)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(ColorTokens.primary)

                ChronirText(
                    "Unlock Unlimited Alarms",
                    style: .titleLarge,
                    color: ColorTokens.textPrimary
                )

                ChronirText(
                    "You've reached the 2-alarm limit on the Free plan. "
                    + "Upgrade to Plus for the full Chronir experience.",
                    style: .bodyMedium,
                    color: ColorTokens.textSecondary
                )
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    FeatureRow(icon: "infinity", text: "Unlimited alarms")
                    FeatureRow(icon: "icloud.and.arrow.up", text: "Cloud backup & sync")
                    FeatureRow(icon: "clock.badge.checkmark", text: "Custom snooze intervals")
                    FeatureRow(icon: "rectangle.on.rectangle", text: "Home screen widgets")
                }
                .padding(.vertical, SpacingTokens.md)

                Spacer()

                VStack(spacing: SpacingTokens.sm) {
                    ChronirButton("Upgrade to Plus") {
                        Task {
                            await viewModel.purchase(tier: .plus)
                        }
                    }

                    ChronirButton("Not Now", style: .ghost) {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.lg)
            .background(ColorTokens.backgroundPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(ColorTokens.primary)
                .frame(width: 28)
            ChronirText(text, style: .bodyMedium, color: ColorTokens.textPrimary)
        }
    }
}

#Preview {
    PaywallView()
}
