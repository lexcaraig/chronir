import SwiftUI

struct OnboardingView: View {
    @Bindable private var settings = UserSettings.shared
    @State private var currentPage = 0
    @State private var permissionGranted = false

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            schedulePage.tag(1)
            permissionPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(ColorTokens.backgroundPrimary)
        .ignoresSafeArea()
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            ChronirIcon(systemName: "bell.fill", size: .large, color: ColorTokens.primary)
                .scaleEffect(2.5)
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
            ChronirIcon(systemName: "calendar.badge.clock", size: .large, color: ColorTokens.warning)
                .scaleEffect(2.5)
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
            ChronirIcon(systemName: "shield.checkered", size: .large, color: ColorTokens.success)
                .scaleEffect(2.5)
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
                    settings.hasCompletedOnboarding = true
                }
            } else {
                ChronirButton("Enable Alarms") {
                    Task {
                        let granted = await PermissionManager.shared.requestAlarmPermission()
                        permissionGranted = granted
                        if granted {
                            settings.hasCompletedOnboarding = true
                        }
                    }
                }
                Button {
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

    private var nextButton: some View {
        ChronirButton("Continue") {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingView()
}
