import SwiftUI
import AlarmKit

struct OnboardingView: View {
    @Bindable private var settings = UserSettings.shared
    @Environment(\.chronirTheme) private var theme
    @State private var currentPage = 0
    @State private var permissionGranted = false
    @State private var permissionDenied = false
    @State private var isRequestingPermission = false
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .largeTitle) private var iconCircleSize: CGFloat = 96

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            schedulePage.tag(1)
            permissionPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .background {
            ColorTokens.backgroundPrimary.ignoresSafeArea()
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(systemName: "bell.fill", color: ColorTokens.primary)
                .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                "Never Forget What Matters",
                style: .headlineTitle,
                alignment: .center
            )
            ChronirText(
                "High-persistence alarms for the obligations that can't be missed.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            nextButton
        }
        .modifier(OnboardingPagePadding())
    }

    // MARK: - Page 2: Schedules

    private var schedulePage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(systemName: "calendar.badge.clock", color: ColorTokens.warning)
                .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                "Weekly, Monthly, Annually",
                style: .headlineTitle,
                alignment: .center
            )
            ChronirText(
                "Set recurring alarms on any cycle. "
                    + "Rent day, medication refills, insurance renewals \u{2014} all covered.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            nextButton
        }
        .modifier(OnboardingPagePadding())
    }

    // MARK: - Page 3: Permissions

    private var permissionPage: some View {
        VStack(spacing: SpacingTokens.lg) {
            Spacer()
            iconCircle(
                systemName: permissionDenied ? "alarm.waves.left.and.right" : "alarm.fill",
                color: permissionDenied ? ColorTokens.warning : ColorTokens.success
            )
            .padding(.bottom, SpacingTokens.lg)
            ChronirText(
                permissionDenied ? "Alarms Are Off" : "Allow Alarms",
                style: .headlineTitle,
                alignment: .center
            )
            .accessibilityAddTraits(.isHeader)
            ChronirText(
                permissionDenied
                    ? "Chronir can't ring until alarms are allowed. "
                        + "Turn on Alarms and Notifications for Chronir in Settings."
                    : "Chronir uses iOS alarms so reminders ring through Silent and Focus, "
                        + "even when the app is closed. "
                        + "You'll also be asked to allow notifications for early warnings.",
                style: .bodySecondary,
                color: ColorTokens.textSecondary,
                alignment: .center
            )
            Spacer()
            permissionActions
        }
        .modifier(OnboardingPagePadding())
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Returning from Settings: pick up a permission the user just turned on.
            guard permissionDenied else { return }
            if AlarmManager.shared.authorizationState == .authorized {
                permissionDenied = false
                permissionGranted = true
            }
        }
    }

    @ViewBuilder
    private var permissionActions: some View {
        if permissionGranted {
            ChronirButton("Get Started") {
                completeOnboarding(skippedPermission: false)
            }
        } else if permissionDenied {
            ChronirButton("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            skipButton("Continue Without Alarms")
        } else {
            ChronirButton(isRequestingPermission ? "Requesting\u{2026}" : "Allow Alarms") {
                guard !isRequestingPermission else { return }
                isRequestingPermission = true
                Task {
                    let granted = await PermissionManager.shared.requestAlarmPermission()
                    isRequestingPermission = false
                    if granted {
                        permissionGranted = true
                        completeOnboarding(skippedPermission: false)
                    } else {
                        permissionDenied = true
                    }
                }
            }
            .disabled(isRequestingPermission)
            skipButton("Skip for Now")
        }
    }

    private func skipButton(_ title: String) -> some View {
        Button {
            completeOnboarding(skippedPermission: true)
        } label: {
            ChronirText(title, style: .bodySecondary, color: ColorTokens.textSecondary)
                .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func completeOnboarding(skippedPermission: Bool) {
        AnalyticsService.shared.logEvent(AnalyticsEvent.onboardingCompleted, parameters: [
            "skipped_permission": skippedPermission
        ])
        settings.hasCompletedOnboarding = true
    }

    // MARK: - Helpers

    private func iconCircle(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.largeTitle.weight(.medium))
            .foregroundStyle(color)
            .frame(width: iconCircleSize, height: iconCircleSize)
            .background(color.opacity(0.12), in: .circle)
            .accessibilityHidden(true)
    }

    private var nextButton: some View {
        ChronirButton("Continue") {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

/// Side padding plus room at the bottom for the page indicator, inside the safe area.
private struct OnboardingPagePadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, SpacingTokens.xl)
            .padding(.top, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxxl)
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
