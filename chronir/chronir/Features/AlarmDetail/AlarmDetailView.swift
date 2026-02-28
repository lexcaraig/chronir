import SwiftUI
import SwiftData
import PhotosUI

struct AlarmDetailView: View {
    let alarmID: UUID
    @Query(sort: \Alarm.nextFireDate) private var existingAlarms: [Alarm]
    @State private var viewModel = AlarmDetailViewModel()
    @State private var showDeleteConfirmation = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        content
            .navigationTitle("Edit Alarm")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let saved = viewModel.updateAlarm(
                            context: modelContext,
                            existingAlarms: existingAlarms
                        )
                        if saved { dismiss() }
                    }
                    .foregroundStyle(ColorTokens.primary)
                }
            }
            .alert("Delete Alarm", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAlarm(context: modelContext)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(viewModel.title)\"?")
            }
            .confirmationDialog(
                viewModel.warningMessage ?? "",
                isPresented: $viewModel.showWarningDialog,
                titleVisibility: .visible
            ) {
                Button("Save Anyway") {
                    if viewModel.forceSave(context: modelContext) {
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Save Failed", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.title) { viewModel.clearWarnings() }
            .onChange(of: viewModel.cycleType) { viewModel.clearWarnings() }
            .onChange(of: viewModel.timesOfDay) { viewModel.clearWarnings() }
            .onChange(of: viewModel.selectedDays) { viewModel.clearWarnings() }
            .onChange(of: viewModel.daysOfMonth) { viewModel.clearWarnings() }
            .onChange(of: viewModel.category) { viewModel.clearWarnings() }
            .onAppear {
                viewModel.loadAlarm(id: alarmID, context: modelContext)
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.alarm == nil {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.alarm != nil {
            alarmForm
        } else {
            Text("Alarm not found")
                .foregroundStyle(ColorTokens.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var alarmForm: some View {
        ScrollView {
            AlarmCreationForm(
                title: $viewModel.title,
                cycleType: $viewModel.cycleType,
                repeatInterval: $viewModel.repeatInterval,
                timesOfDay: $viewModel.timesOfDay,
                isPersistent: $viewModel.isPersistent,
                note: $viewModel.note,
                selectedDays: $viewModel.selectedDays,
                daysOfMonth: $viewModel.daysOfMonth,
                annualMonth: $viewModel.annualMonth,
                annualDay: $viewModel.annualDay,
                annualYear: $viewModel.annualYear,
                startMonth: $viewModel.startMonth,
                startYear: $viewModel.startYear,
                category: $viewModel.category,
                preAlarmOffsets: $viewModel.preAlarmOffsets,
                oneTimeDate: $viewModel.oneTimeDate,
                soundName: $viewModel.soundName,
                followUpInterval: $viewModel.followUpInterval,
                isPlusTier: SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank,
                titleError: viewModel.titleError
            )

            if isPlusTier || viewModel.selectedImage != nil {
                photoSection
                    .padding(.horizontal, SpacingTokens.lg)
            }

            if isPlusTier {
                NavigationLink(
                    destination: CompletionHistoryView(
                        alarmID: alarmID,
                        alarmTitle: viewModel.title
                    )
                ) {
                    HStack {
                        Image(systemName: "clock.badge.checkmark")
                        ChronirText("View History", style: .bodyMedium, color: ColorTokens.primary)
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.top, SpacingTokens.md)
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Alarm")
                }
                .frame(maxWidth: .infinity)
                .padding(SpacingTokens.md)
            }
            .padding(.horizontal, SpacingTokens.md)
            .padding(.top, SpacingTokens.lg)
        }
        .background(ColorTokens.backgroundPrimary)
    }

    private var isPlusTier: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText(
                isPlusTier ? "Photo (optional)" : "Photo",
                style: .labelMedium,
                color: ColorTokens.textSecondary
            )

            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))

                    if isPlusTier {
                        Button {
                            viewModel.selectedImage = nil
                            viewModel.removePhoto = true
                            selectedPhotoItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white, .black.opacity(0.5))
                        }
                        .padding(SpacingTokens.xs)
                    }
                }
            }

            if isPlusTier {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: SpacingTokens.sm) {
                        Image(systemName: "photo.badge.plus")
                        ChronirText(
                            viewModel.selectedImage == nil ? "Add Photo" : "Change Photo",
                            style: .bodyMedium,
                            color: ColorTokens.primary
                        )
                    }
                }
                .onChange(of: selectedPhotoItem) {
                    Task {
                        if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.selectedImage = image
                            viewModel.removePhoto = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlarmDetailView(alarmID: UUID())
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
