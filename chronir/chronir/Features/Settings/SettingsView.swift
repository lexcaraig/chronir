import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Bindable private var settings = UserSettings.shared

    var body: some View {
        List {
            alarmBehaviorSection
            timezoneSection
            appearanceSection
            notificationsSection
            historySection
            backupSection
            developerSection
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
            NavigationLink(destination: SoundPicker()) {
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
            ChronirText("Alarm Behavior", style: .labelLarge, color: ColorTokens.textSecondary)
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
            ChronirText("Timezone", style: .labelLarge, color: ColorTokens.textSecondary)
        } footer: {
            ChronirText(
                settings.timezoneMode == .fixed
                    ? "Alarms fire at the time set in their original timezone."
                    : "Alarms adjust to your current timezone.",
                style: .caption,
                color: ColorTokens.textSecondary
            )
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section {
            NavigationLink(destination: WallpaperPickerView()) {
                HStack {
                    ChronirText("Background Wallpaper", style: .bodyPrimary)
                    Spacer()
                    if let name = settings.wallpaperImageName,
                       let data = try? Data(contentsOf: WallpaperPickerView.wallpaperURL(for: name)),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
                    } else {
                        ChronirText(
                            "None",
                            style: .bodySecondary,
                            color: ColorTokens.textSecondary
                        )
                    }
                }
            }

            ChronirToggle(
                label: "Group Alarms by Category",
                isOn: $settings.groupAlarmsByCategory
            )
        } header: {
            ChronirText("Appearance", style: .labelLarge, color: ColorTokens.textSecondary)
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
        } header: {
            ChronirText("Notifications", style: .labelLarge, color: ColorTokens.textSecondary)
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
            ChronirText("History", style: .labelLarge, color: ColorTokens.textSecondary)
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

            NavigationLink(destination: LocalBackupInfoView()) {
                HStack {
                    ChronirText("Backup & Sync", style: .bodyPrimary)
                    Spacer()
                    ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
                }
            }
        } header: {
            ChronirText("Data", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    private var tierBadgeColor: Color {
        switch SubscriptionService.shared.currentTier {
        case .free: return ColorTokens.textSecondary
        case .plus: return ColorTokens.primary
        case .premium: return ColorTokens.warning
        case .family: return ColorTokens.success
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
            ChronirText("Developer", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                ChronirText("Version", style: .bodyPrimary)
                Spacer()
                ChronirText("1.0.0", style: .bodySecondary, color: ColorTokens.textSecondary)
            }
            HStack {
                ChronirText("Privacy Policy", style: .bodyPrimary)
                Spacer()
                ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
            }
            HStack {
                ChronirText("Terms of Service", style: .bodyPrimary)
                Spacer()
                ChronirIcon(systemName: "chevron.right", size: .small, color: ColorTokens.textSecondary)
            }
        } header: {
            ChronirText("About", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
