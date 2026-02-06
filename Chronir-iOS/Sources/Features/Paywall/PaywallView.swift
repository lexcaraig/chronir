import SwiftUI

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SingleColumnTemplate(title: "Upgrade") {
                Text("TODO: PaywallView")
                    .foregroundStyle(ColorTokens.textPrimary)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
