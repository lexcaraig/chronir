import SwiftUI

struct SplashView: View {
    @State private var animationPhase: CGFloat = 0
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            // Animated gradient background
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let angle = Angle.degrees(t.truncatingRemainder(dividingBy: 360) * 20)
                let startPoint = UnitPoint(
                    x: 0.5 + 0.5 * cos(angle.radians),
                    y: 0.5 + 0.5 * sin(angle.radians)
                )
                let endPoint = UnitPoint(
                    x: 0.5 - 0.5 * cos(angle.radians),
                    y: 0.5 - 0.5 * sin(angle.radians)
                )

                LinearGradient(
                    colors: [
                        ColorTokens.gradientStart,
                        ColorTokens.gradientMid,
                        ColorTokens.gradientEnd,
                        ColorTokens.gradientMid
                    ],
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .ignoresSafeArea()
            }

            // Logo + app name
            VStack(spacing: SpacingTokens.md) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(.white)

                Text("Chronir")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
