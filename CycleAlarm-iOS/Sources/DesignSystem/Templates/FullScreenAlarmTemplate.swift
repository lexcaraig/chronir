import SwiftUI

struct FullScreenAlarmTemplate<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            ColorTokens.backgroundPrimary
                .ignoresSafeArea()

            content()
        }
        .statusBarHidden(true)
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
