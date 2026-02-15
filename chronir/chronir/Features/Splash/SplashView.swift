import SwiftUI

struct SplashView: View {
    @Environment(\.chronirTheme) private var theme
    @State private var logoScale: CGFloat = 0.85
    @State private var logoOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            ColorTokens.backgroundPrimary
                .ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
        }
    }
}

#Preview("Light") {
    SplashView()
        .environment(\.chronirTheme, .light)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SplashView()
        .environment(\.chronirTheme, .dark)
        .preferredColorScheme(.dark)
}
