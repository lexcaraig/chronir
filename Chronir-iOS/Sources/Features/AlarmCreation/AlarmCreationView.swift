import SwiftUI

struct AlarmCreationView: View {
    @State private var viewModel = AlarmCreationViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ModalSheetTemplate(
            title: "New Alarm",
            onDismiss: { dismiss() },
            onSave: {
                Task {
                    await viewModel.saveAlarm()
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            },
            content: {
                AlarmCreationForm(
                    title: $viewModel.title,
                    cycleType: $viewModel.cycleType,
                    scheduledTime: $viewModel.scheduledTime,
                    isPersistent: $viewModel.isPersistent,
                    note: $viewModel.note,
                    selectedDays: $viewModel.selectedDays,
                    dayOfMonth: $viewModel.dayOfMonth
                )
            }
        )
    }
}

#Preview {
    AlarmCreationView()
}
