import SwiftUI

struct SplashView: View {
    @State private var bellRotation: Double = 0
    @State private var gradientOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            // Base navy — matches launch screen exactly
            ColorTokens.gradientStart
                .ignoresSafeArea()

            // Gradient fades in over the navy base
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let drift = 0.08 * sin(t * 0.4)

                LinearGradient(
                    colors: [
                        ColorTokens.gradientStart,
                        ColorTokens.gradientMid,
                        ColorTokens.gradientEnd,
                    ],
                    startPoint: UnitPoint(x: drift, y: drift),
                    endPoint: UnitPoint(x: 1.0 - drift, y: 1.0 - drift)
                )
                .ignoresSafeArea()
                .opacity(gradientOpacity)
            }

            // Logo — visible immediately (matches launch screen), bell ring plays after
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(bellRotation), anchor: .top)
        }
        .onAppear {
            // Fade gradient in so navy transitions smoothly
            withAnimation(.easeIn(duration: 0.8)) {
                gradientOpacity = 1.0
            }

            // Bell ring after a brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
