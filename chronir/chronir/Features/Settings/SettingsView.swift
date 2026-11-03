import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Bindable private var settings = UserSettings.shared
    @State private var wallpaperThumbnail: UIImage?

    private var isPlusTier: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    var body: some View {
        List {
            alarmBehaviorSection
            timezoneSection
            appearanceSection
            notificationsSection
            historySection
            backupSection
            #if DEBUG
            developerSection
            #endif
            aboutSection
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle("Settings")
        .task {
            await viewModel.loadNotificationStatus()
        }
    }

    // MARK: - Alarm Behavior

    private var alarmBehaviorSection: some View {
        Section {
            ChronirToggle(label: "Snooze Enabled", isOn: $settings.snoozeEnabled)
            ChronirToggle(label: "Slide to Stop", isOn: $settings.slideToStopEnabled)
            ChronirToggle(label: "Haptic Feedback", isOn: $settings.hapticsEnabled)
            NavigationLink(destination: DefaultSoundPicker()) {
                HStack {
                    ChronirText("Alarm Sound", style: .bodyPrimary)
                    Spacer()
                    ChronirText(
                        soundDisplayName,
                        style: .bodySecondary,
                        color: ColorTokens.textSecondary
                    )
                }
            }
        } header: {
            Text("Alarm Behavior")
        } footer: {
            Text("Snooze and dismiss settings apply in-app only. Lock screen behavior is controlled by iOS.")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private var soundDisplayName: String {
        AlarmSoundService.availableSounds
            .first { $0.name == settings.selectedAlarmSound }?.displayName
            ?? settings.selectedAlarmSound
    }

    // MARK: - Timezone

    private var timezoneSection: some View {
        Section {
            ChronirToggle(
                label: "Fixed Timezone",
                isOn: Binding(
                    get: { settings.timezoneMode == .fixed },
                    set: { settings.timezoneMode = $0 ? .fixed : .floating }
                )
            )
        } header: {
            Text("Timezone")
        } footer: {
            Text(
                settings.timezoneMode == .fixed
                    ? "Alarms fire at the time set in their original timezone."
                    : "Alarms adjust to your current timezone."
            )
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $settings.themePreference) {
                ForEach(ThemePreference.allCases, id: \.self) { pref in
                    Text(pref.displayName).tag(pref)
                }
            }
            .pickerStyle(.segmented)

            if settings.themePreference == .liquidGlass {
                NavigationLink(destination: WallpaperPickerView()) {
                    HStack {
                        ChronirText("Background Wallpaper", style: .bodyPrimary)
                        Spacer()
                        if settings.wallpaperImageName != nil, let wallpaperThumbnail {
                            Image(uiImage: wallpaperThumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
                                .accessibilityLabel("Custom wallpaper")
                        } else {
                            ChronirText(
                                "None",
                                style: .bodySecondary,
                                color: ColorTokens.textSecondary
                            )
                        }
                    }
                }
                .task(id: settings.wallpaperImageName) {
                    wallpaperThumbnail = await WallpaperPickerView.loadThumbnail(named: settings.wallpaperImageName)
                }
            }

            Picker("Text Size", selection: $settings.textSizePreference) {
                ForEach(TextSizePreference.allCases, id: \.self) { pref in
                    Text(pref.displayName).tag(pref)
                }
            }
            .pickerStyle(.segmented)

            ChronirToggle(
                label: "Group Alarms by Category",
                isOn: $settings.groupAlarmsByCategory
            )
        } header: {
            Text("Appearance")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            PermissionStatusRow(
                label: "Notifications",
                status: viewModel.notificationStatus
            )
            ChronirToggle(
                label: "Live Activity Countdown",
                isOn: $settings.liveActivityEnabled
            )
            .onChange(of: settings.liveActivityEnabled) {
                Task { await LiveActivityService.shared.refreshLiveActivity() }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Shows a countdown on your Lock Screen when an alarm is within 1 hour.")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - History

    private var historySection: some View {
        Section {
            NavigationLink(destination: CompletionHistoryView()) {
                HStack {
                    ChronirText("Completion History", style: .bodyPrimary)
                    Spacer()
                    if SubscriptionService.shared.currentTier == .free {
                        ChronirIcon(systemName: "lock.fill", size: .small, color: ColorTokens.textSecondary)
                    }
                }
            }
        } header: {
            Text("History")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Subscription & Data

    private var backupSection: some View {
        Section {
            NavigationLink(destination: SubscriptionManagementView()) {
                HStack {
                    ChronirText("Subscription", style: .bodyPrimary)
                    Spacer()
                    ChronirBadge(
                        SubscriptionService.shared.currentTier.displayName,
                        color: tierBadgeColor
                    )
                }
            }

            if isPlusTier {
                NavigationLink(destination: AccountView()) {
                    HStack {
                        ChronirText("Account & Sync", style: .bodyPrimary)
                        Spacer()
                        if AuthService.shared.isSignedIn {
                            ChronirBadge("Signed In", color: ColorTokens.success)
                        } else {
                            ChronirText("Sign In", style: .bodySecondary, color: ColorTokens.textSecondary)
                        }
                    }
                }
            } else {
                NavigationLink(destination: LocalBackupInfoView()) {
                    ChronirText("Backup & Sync", style: .bodyPrimary)
                }
            }
        } header: {
            Text("Data")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private var tierBadgeColor: Color {
        switch SubscriptionService.shared.currentTier {
        case .free: return ColorTokens.textSecondary
        case .plus: return ColorTokens.primary
        case .premium: return ColorTokens.badgeWarning
        case .family: return ColorTokens.badgeSuccess
        }
    }

    // MARK: - Developer

    private var developerSection: some View {
        Section {
            NavigationLink(destination: ComponentCatalog()) {
                HStack {
                    ChronirText("Design System", style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "paintpalette", size: .small, color: ColorTokens.textSecondary)
                }
            }
        } header: {
            Text("Developer")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                ChronirText("Version", style: .bodyPrimary)
                Spacer()
                ChronirText(appVersion, style: .bodySecondary, color: ColorTokens.textSecondary)
            }
            .accessibilityElement(children: .combine)
            NavigationLink(destination: HowAlarmsWorkView()) {
                ChronirText("How Alarms Work", style: .bodyPrimary)
            }
            NavigationLink(destination: LegalDocumentView(title: "FAQ", rawURL: faqURL)) {
                ChronirText("FAQ", style: .bodyPrimary)
            }
            NavigationLink(destination: LegalDocumentView(title: "Privacy Policy", rawURL: privacyURL)) {
                ChronirText("Privacy Policy", style: .bodyPrimary)
            }
            NavigationLink(destination: LegalDocumentView(title: "Terms of Service", rawURL: termsURL)) {
                ChronirText("Terms of Service", style: .bodyPrimary)
            }
        } header: {
            Text("About")
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    /// "1.2.4 (17)" from the bundle, so it can never go stale.
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "\u{2014}"
        guard let build = info?["CFBundleVersion"] as? String else { return version }
        return "\(version) (\(build))"
    }

    // Bundled so the FAQ matches this build and opens offline; the Gist is only a fallback.
    private let faqURL = Bundle.main.url(forResource: "FAQ", withExtension: "md")
        // swiftlint:disable:next force_unwrapping
        ?? URL(string: "https://gist.githubusercontent.com/lexcaraig/46b6ba8d4fcfc7768c86e22d7f056f6d/raw/")!
    // swiftlint:disable:next force_unwrapping
    private let privacyURL = URL(string: "https://gist.githubusercontent.com/lexcaraig/1ecd278bb8c97c9d4725f5c9b63cd28c/raw/")!
    // swiftlint:disable:next force_unwrapping
    private let termsURL = URL(string: "https://gist.githubusercontent.com/lexcaraig/b5087828d62c2f0aa190b9814f57bcf9/raw/")!
}

#Preview("Light") {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.dark)
}
