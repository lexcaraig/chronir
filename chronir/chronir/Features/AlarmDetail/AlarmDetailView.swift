import SwiftUI

struct AlarmDetailView: View {
    let alarmID: UUID
    @State private var viewModel = AlarmDetailViewModel()
    @State private var showDeleteConfirmation = false
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
                        scheduledTime: $viewModel.scheduledTime,
                        isPersistent: $viewModel.isPersistent,
                        note: $viewModel.note,
                        selectedDays: $viewModel.selectedDays,
                        daysOfMonth: $viewModel.daysOfMonth,
                        category: $viewModel.category
                    )

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
}

#Preview {
    NavigationStack {
        AlarmDetailView(alarmID: UUID())
    }
    .modelContainer(for: Alarm.self, inMemory: true)
}
