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
            // Keep the last row clear of the floating action (56pt button + its padding).
            .contentMargins(.bottom, hasFloatingAction ? SpacingTokens.xxl + SpacingTokens.xl : 0, for: .scrollContent)
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle(title)

            floatingAction()
                .padding(SpacingTokens.lg)
        }
    }
}

private extension SingleColumnTemplate {
    var hasFloatingAction: Bool { FloatingAction.self != EmptyView.self }
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

#Preview("Light") {
    NavigationStack {
        SingleColumnTemplate(title: "Alarms") {
            Text("Content goes here")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

private let fabSize = SpacingTokens.xxl + SpacingTokens.xs // 56pt

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
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(ColorTokens.onPrimary)
                        .frame(width: fabSize, height: fabSize)
                        .chronirGlassTintedCircle(tint: ColorTokens.primary)
                }
            )
            .accessibilityLabel("New Alarm")
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        SingleColumnTemplate(title: "Alarms") {
            Text("Content goes here")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
    .environment(\.colorScheme, .dark)
}
