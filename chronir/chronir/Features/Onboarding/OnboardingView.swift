import SwiftUI

struct OnboardingView: View {
    @Bindable private var settings = UserSettings.shared
    @Environment(\.chronirTheme) private var theme
    @State private var currentPage = 0
    @State private var permissionGranted = false

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            schedulePage.tag(1)
            permissionPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background {
            ColorTokens.backgroundPrimary.ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(systemName: "bell.fill", color: ColorTokens.primary)
                .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                "Never Forget\nWhat Matters",
                style: .headlineTitle,
                alignment: .center
            )
            ChronirText(
                "High-persistence alarms for the obligations\nthat can't be missed.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            nextButton
        }
        .padding(SpacingTokens.xl)
    }

    // MARK: - Page 2: Schedules

    private var schedulePage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(systemName: "calendar.badge.clock", color: ColorTokens.warning)
                .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                "Weekly, Monthly,\nAnnually",
                style: .headlineTitle,
                alignment: .center
            )
            ChronirText(
                "Set recurring alarms on any cycle.\n"
                    + "Rent day, medication refills,\n"
                    + "insurance renewals \u{2014} all covered.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            nextButton
        }
        .padding(SpacingTokens.xl)
    }

    // MARK: - Page 3: Permissions

    private var permissionPage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(systemName: "shield.checkered", color: ColorTokens.success)
                .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                "Stay Notified",
                style: .headlineTitle,
                alignment: .center
            )
            ChronirText(
                "Chronir needs notification access to fire alarms\neven when the app is closed.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            if permissionGranted {
                ChronirButton("Get Started") {
                    AnalyticsService.shared.logEvent(AnalyticsEvent.onboardingCompleted, parameters: [
                        "skipped_permission": false
                    ])
                    settings.hasCompletedOnboarding = true
                }
            } else {
                ChronirButton("Enable Alarms") {
                    Task {
                        let granted = await PermissionManager.shared.requestAlarmPermission()
                        permissionGranted = granted
                        if granted {
                            AnalyticsService.shared.logEvent(AnalyticsEvent.onboardingCompleted, parameters: [
                                "skipped_permission": false
                            ])
                            settings.hasCompletedOnboarding = true
                        }
                    }
                }
                Button {
                    AnalyticsService.shared.logEvent(AnalyticsEvent.onboardingCompleted, parameters: [
                        "skipped_permission": true
                    ])
                    settings.hasCompletedOnboarding = true
                } label: {
                    ChronirText("Skip for now", style: .bodySecondary, color: ColorTokens.textSecondary)
                }
                .padding(.top, SpacingTokens.xs)
            }
        }
        .padding(SpacingTokens.xl)
    }

    // MARK: - Helpers

    private func iconCircle(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 96, height: 96)
            .background(color.opacity(0.12), in: .circle)
    }

    private var nextButton: some View {
        ChronirButton("Continue") {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

#Preview("Light") {
    OnboardingView()
        .environment(\.chronirTheme, .light)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    OnboardingView()
        .environment(\.chronirTheme, .dark)
        .preferredColorScheme(.dark)
}
