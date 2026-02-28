import SwiftUI
import SwiftData
import PhotosUI

struct AlarmCreationView: View {
    let modelContext: ModelContext
    @Query(sort: \Alarm.nextFireDate) private var existingAlarms: [Alarm]
    @State private var title = ""
    @State private var cycleType: CycleType = .weekly
    @State private var repeatInterval: Int = 1
    @State private var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    @State private var isPersistent = false
    @State private var note = ""
    @State private var selectedDays: Set<Int> = [2]
    @State private var daysOfMonth: Set<Int> = [1]
    @State private var annualMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var annualDay: Int = Calendar.current.component(.day, from: Date())
    @State private var annualYear: Int = Calendar.current.component(.year, from: Date())
    @State private var startMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var startYear: Int = Calendar.current.component(.year, from: Date())
    @State private var category: AlarmCategory?
    @State private var preAlarmOffsets: Set<PreAlarmOffset> = []
    @State private var oneTimeDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var soundName: String = UserSettings.shared.selectedAlarmSound
    @State private var followUpInterval: FollowUpInterval = .thirtyMinutes
    @State private var saveError: String?
    @State private var titleError: String?
    @State private var showWarningDialog = false
    @State private var warningMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showTemplateLibrary = false
    @Environment(\.dismiss) private var dismiss

    private var hasUnsavedChanges: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedImage != nil
            || category != nil
            || timesOfDay != [TimeOfDay(hour: 8, minute: 0)]
            || selectedDays != [2]
            || isPersistent
    }

    var body: some View {
        ModalSheetTemplate(
            title: "New Alarm",
            onDismiss: { dismiss() },
            onSave: { saveAndDismiss() },
            content: {
                AlarmCreationForm(
                    title: $title,
                    cycleType: $cycleType,
                    repeatInterval: $repeatInterval,
                    timesOfDay: $timesOfDay,
                    isPersistent: $isPersistent,
                    note: $note,
                    selectedDays: $selectedDays,
                    daysOfMonth: $daysOfMonth,
                    annualMonth: $annualMonth,
                    annualDay: $annualDay,
                    annualYear: $annualYear,
                    startMonth: $startMonth,
                    startYear: $startYear,
                    category: $category,
                    preAlarmOffsets: $preAlarmOffsets,
                    oneTimeDate: $oneTimeDate,
                    soundName: $soundName,
                    followUpInterval: $followUpInterval,
                    isPlusTier: SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank,
                    titleError: titleError
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showTemplateLibrary = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("Templates")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(ColorTokens.primary)
                        }
                    }
                }

                if SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank {
                    photoSection
                        .padding(.horizontal, SpacingTokens.lg)
                }
            }
        )
        .sheet(isPresented: $showTemplateLibrary) {
            TemplateLibraryView { template in
                applyTemplate(template)
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
        .confirmationDialog(warningMessage, isPresented: $showWarningDialog, titleVisibility: .visible) {
            Button("Save Anyway") {
                forceSave()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: title) {
            titleError = nil
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText("Photo (optional)", style: .labelMedium, color: ColorTokens.textSecondary)

            if let selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))

                    Button {
                        self.selectedImage = nil
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white, .black.opacity(0.5))
                    }
                    .padding(SpacingTokens.xs)
                }
            }

            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: SpacingTokens.sm) {
                    Image(systemName: "photo.badge.plus")
                    ChronirText(
                        selectedImage == nil ? "Add Photo" : "Change Photo",
                        style: .bodyMedium,
                        color: ColorTokens.primary
                    )
                }
            }
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }

    private func saveAndDismiss() {
        let schedule = buildSchedule()

        let result = AlarmValidator.validate(
            title: title,
            note: note,
            cycleType: cycleType,
            schedule: schedule,
            timesOfDay: timesOfDay,
            daysOfMonth: daysOfMonth,
            existingAlarms: existingAlarms
        )

        // Hard errors block save
        if !result.isValid {
            if result.errors.contains(.emptyTitle) {
                titleError = "Alarm name is required."
            }
            if UserSettings.shared.hapticsEnabled {
                HapticService.shared.playError()
            }
            return
        }

        // Soft warnings: show confirmation dialog
        let actionableWarnings = result.warnings.filter { $0 != .monthlyDay31 }
        if let firstWarning = actionableWarnings.first {
            warningMessage = firstWarning.displayMessage
            showWarningDialog = true
            return
        }

        performSave()
    }

    private func forceSave() {
        performSave()
    }

    private func performSave() {
        let trimmedTitle = AlarmValidator.trimmedTitle(title)
        let trimmedNote = AlarmValidator.trimmedNote(note)
        let calendar = Calendar.current
        let schedule = buildSchedule()

        let alarm = Alarm(
            title: trimmedTitle,
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            preAlarmMinutes: preAlarmOffsets.contains(.oneDay) ? 1440 : (preAlarmOffsets.isEmpty ? 0 : 1),
            category: category?.rawValue,
            note: trimmedNote
        )
        alarm.preAlarmOffsets = Array(preAlarmOffsets)
        alarm.followUpInterval = followUpInterval
        if soundName != UserSettings.shared.selectedAlarmSound {
            alarm.soundName = soundName
        }

        if cycleType == .oneTime {
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
            alarm.nextFireDate = calendar.date(
                bySettingHour: firstTime.hour, minute: firstTime.minute,
                second: 0, of: oneTimeDate
            ) ?? oneTimeDate
        } else if cycleType == .annual {
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
            let targetDate = calendar.date(from: DateComponents(
                year: annualYear, month: annualMonth, day: annualDay,
                hour: firstTime.hour, minute: firstTime.minute
            )) ?? Date()
            alarm.nextFireDate = targetDate > Date()
                ? targetDate
                : DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        } else if repeatInterval > 1 && (cycleType == .monthlyDate || cycleType == .monthlyRelative) {
            let firstTime = timesOfDay.min() ?? TimeOfDay(hour: 8, minute: 0)
            let firstDay = cycleType == .monthlyDate ? Array(daysOfMonth).min() ?? 1 : 1
            let targetDate = calendar.date(from: DateComponents(
                year: startYear, month: startMonth, day: firstDay,
                hour: firstTime.hour, minute: firstTime.minute
            )) ?? Date()
            alarm.nextFireDate = targetDate > Date()
                ? targetDate
                : DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        } else {
            alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        }

        if let selectedImage {
            alarm.photoFileName = PhotoStorageService.savePhoto(selectedImage, for: alarm.id)
        }

        modelContext.insert(alarm)

        do {
            try modelContext.save()
            if UserSettings.shared.hapticsEnabled {
                HapticService.shared.playSuccess()
            }
            let alarmToSync = alarm
            Task {
                do {
                    _ = await PermissionManager.shared.requestAlarmPermission()
                    try await AlarmScheduler.shared.scheduleAlarm(alarmToSync)
                } catch {
                    // Schedule failed — alarm will fire on next app launch
                }
                await CloudSyncService.shared.pushAlarmModel(alarmToSync)
            }
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func applyTemplate(_ template: AlarmTemplate) {
        title = template.title
        cycleType = template.cycleType
        repeatInterval = template.repeatInterval
        category = template.category
        note = template.suggestedNote
        if !template.daysOfMonth.isEmpty {
            daysOfMonth = template.daysOfMonth
        }
    }

    private func buildSchedule() -> Schedule {
        switch cycleType {
        case .weekly:
            return .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: repeatInterval)
        case .monthlyDate:
            return .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: repeatInterval)
        case .monthlyRelative:
            return .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: repeatInterval)
        case .annual:
            return .annual(
                month: annualMonth,
                dayOfMonth: annualDay,
                interval: repeatInterval
            )
        case .customDays:
            return .customDays(intervalDays: repeatInterval, startDate: Date())
        case .oneTime:
            return .oneTime(fireDate: oneTimeDate)
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Alarm.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    AlarmCreationView(modelContext: container.mainContext)
}
