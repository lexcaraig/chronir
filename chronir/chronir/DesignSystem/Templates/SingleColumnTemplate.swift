import SwiftUI

struct SingleColumnTemplate<Content: View, FloatingAction: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    @ViewBuilder var floatingAction: () -> FloatingAction

    init(
        title: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder floatingAction: @escaping () -> FloatingAction
    ) {
        self.title = title
        self.content = content
        self.floatingAction = floatingAction
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: SpacingTokens.lg) {
                    content()
                }
                .padding(.horizontal, 0)
                .padding(.vertical, SpacingTokens.md)
            }
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle(title)

            floatingAction()
                .padding(SpacingTokens.lg)
        }
    }
}

extension SingleColumnTemplate where FloatingAction == EmptyView {
    init(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
        self.floatingAction = { EmptyView() }
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

#Preview("With FAB") {
    NavigationStack {
        SingleColumnTemplate(title: "Alarms") {
            Text("Content goes here")
                .foregroundStyle(ColorTokens.textPrimary)
        } floatingAction: {
            Button(
                action: {},
                label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(ColorTokens.primary)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            )
        }
    }
}
