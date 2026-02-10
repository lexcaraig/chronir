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
    @State private var saveError: String?
    @State private var conflictWarning: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

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
                    category: $category
                )

                photoSection
                    .padding(.horizontal, SpacingTokens.lg)

                if let conflictWarning {
                    HStack(spacing: SpacingTokens.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(ColorTokens.warning)
                        ChronirText(conflictWarning, style: .bodySmall, color: ColorTokens.warning)
                    }
                    .padding(SpacingTokens.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ColorTokens.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
                    .padding(.horizontal, SpacingTokens.md)
                }
            }
        )
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
        .onChange(of: category) {
            conflictWarning = nil
        }
        .onChange(of: cycleType) {
            repeatInterval = 1
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
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            saveError = "Please enter an alarm name."
            return
        }

        let calendar = Calendar.current

        let schedule: Schedule
        switch cycleType {
        case .weekly:
            schedule = .weekly(daysOfWeek: Array(selectedDays).sorted(), interval: repeatInterval)
        case .monthlyDate:
            schedule = .monthlyDate(daysOfMonth: Array(daysOfMonth).sorted(), interval: repeatInterval)
        case .monthlyRelative:
            schedule = .monthlyRelative(weekOfMonth: 1, dayOfWeek: 2, interval: repeatInterval)
        case .annual:
            schedule = .annual(
                month: annualMonth,
                dayOfMonth: annualDay,
                interval: repeatInterval
            )
        case .customDays:
            schedule = .customDays(intervalDays: repeatInterval, startDate: Date())
        }

        let alarm = Alarm(
            title: trimmedTitle,
            cycleType: cycleType,
            timesOfDay: timesOfDay,
            schedule: schedule,
            persistenceLevel: isPersistent ? .full : .notificationOnly,
            category: category?.rawValue,
            note: note.isEmpty ? nil : note
        )

        if cycleType == .annual {
            // Use the user-selected year directly so "Sep 10, 2029" doesn't snap to 2026
            let firstTime = timesOfDay.sorted().first ?? TimeOfDay(hour: 8, minute: 0)
            let targetDate = calendar.date(from: DateComponents(
                year: annualYear, month: annualMonth, day: annualDay,
                hour: firstTime.hour, minute: firstTime.minute
            )) ?? Date()
            alarm.nextFireDate = targetDate > Date()
                ? targetDate
                : DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        } else if repeatInterval > 1 && (cycleType == .monthlyDate || cycleType == .monthlyRelative) {
            // Use the user-selected starting month/year for multi-month intervals
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

        // Check for same-day conflicts within the same category (non-blocking, show once)
        if conflictWarning == nil, let selectedCategory = category {
            let newFireDay = calendar.startOfDay(for: alarm.nextFireDate)
            let conflicts = existingAlarms.filter { existing in
                existing.isEnabled
                    && existing.alarmCategory == selectedCategory
                    && calendar.startOfDay(for: existing.nextFireDate) == newFireDay
            }
            if !conflicts.isEmpty {
                let names = conflicts.map(\.title).joined(separator: ", ")
                conflictWarning = "\(names) also fire\(conflicts.count == 1 ? "s" : "") on the same day."
                return
            }
        }

        if let selectedImage {
            alarm.photoFileName = PhotoStorageService.savePhoto(selectedImage, for: alarm.id)
        }

        modelContext.insert(alarm)

        do {
            try modelContext.save()
            // Schedule the notification
            Task {
                do {
                    _ = await PermissionManager.shared.requestAlarmPermission()
                    try await AlarmScheduler.shared.scheduleAlarm(alarm)
                } catch {
                    print("Failed to schedule notification: \(error)")
                }
            }
            dismiss()
        } catch {
            saveError = error.localizedDescription
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
