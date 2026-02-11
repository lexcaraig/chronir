import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: CGFloat = 0
    @State private var bellRotation: Double = 0
    @State private var isRinging = false

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
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(bellRotation), anchor: .top)
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Start subtle bell ring after logo appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startBellRing()
            }
        }
    }

    private func startBellRing() {
        // Subtle swing: right → left → right → left → settle
        let swingDuration = 0.12
        withAnimation(.easeInOut(duration: swingDuration)) {
            bellRotation = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + swingDuration) {
            withAnimation(.easeInOut(duration: swingDuration)) {
                bellRotation = -6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + swingDuration * 2) {
            withAnimation(.easeInOut(duration: swingDuration)) {
                bellRotation = 4
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + swingDuration * 3) {
            withAnimation(.easeInOut(duration: swingDuration)) {
                bellRotation = -2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + swingDuration * 4) {
            withAnimation(.easeInOut(duration: swingDuration * 1.5)) {
                bellRotation = 0
            }
        }
    }
}

#Preview {
    SplashView()
}
