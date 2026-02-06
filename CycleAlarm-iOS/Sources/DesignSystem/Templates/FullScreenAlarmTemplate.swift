import SwiftUI

struct FullScreenAlarmTemplate<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            ColorTokens.backgroundPrimary
                .ignoresSafeArea()

            content()
        }
        #if os(iOS)
        .statusBarHidden(true)
        #endif
    }
}

#Preview {
    FullScreenAlarmTemplate {
        VStack {
            Text("ALARM FIRING")
                .font(TypographyTokens.displayLarge)
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}
