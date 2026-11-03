import SwiftUI

/// Full-screen firing surface. Always dark, whatever the app theme: it paints `firingBackground`
/// from the first frame (no light flash in a dark room) and pins the color scheme to `.dark`, so any
/// adaptive token used inside resolves to its dark value.
struct FullScreenAlarmTemplate<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            ColorTokens.firingBackground
                .ignoresSafeArea()

            content()
        }
        .environment(\.colorScheme, .dark)
        #if os(iOS)
        .statusBarHidden(true)
        #endif
    }
}

#Preview("Firing (always dark)") {
    FullScreenAlarmTemplate {
        VStack(spacing: SpacingTokens.lg) {
            ChronirText(
                "Renew Passport",
                style: .headlineLarge,
                color: ColorTokens.firingTextPrimary,
                alignment: .center
            )
            ChronirText("9:00 AM", style: .displaySmall, color: ColorTokens.firingTextSecondary)
            SnoozeOptionBar(onSnooze: { _ in })
            ChronirButton("Mark as Done") {}
                .padding(.horizontal, SpacingTokens.lg)
        }
    }
}

#Preview("Light app theme") {
    FullScreenAlarmTemplate {
        ChronirButton("Mark as Done") {}
            .padding()
    }
    .environment(\.colorScheme, .light)
}
