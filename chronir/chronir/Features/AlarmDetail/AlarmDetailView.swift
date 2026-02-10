import SwiftUI
import PhotosUI

struct AlarmDetailView: View {
    let alarmID: UUID
    @State private var viewModel = AlarmDetailViewModel()
    @State private var showDeleteConfirmation = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.alarm == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.alarm != nil {
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
                        category: $viewModel.category
                    )

                    photoSection
                        .padding(.horizontal, SpacingTokens.lg)

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
            } else {
                Text("Alarm not found")
                    .foregroundStyle(ColorTokens.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Edit Alarm")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.updateAlarm(context: modelContext)
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
                .foregroundStyle(ColorTokens.primary)
            }
        }
        .confirmationDialog("Delete this alarm?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteAlarm(context: modelContext)
                dismiss()
            }
        }
        .onAppear {
            viewModel.loadAlarm(id: alarmID, context: modelContext)
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText("Photo (optional)", style: .labelMedium, color: ColorTokens.textSecondary)

            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))

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

#Preview {
    NavigationStack {
        AlarmDetailView(alarmID: UUID())
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
