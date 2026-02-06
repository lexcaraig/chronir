import SwiftUI

struct SingleColumnTemplate<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SpacingTokens.lg) {
                content()
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.vertical, SpacingTokens.md)
        }
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        SingleColumnTemplate(title: "Alarms") {
            Text("Content goes here")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}
