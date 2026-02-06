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
                    dismiss()
                }
            }
        ) {
            AlarmCreationForm(
                title: $viewModel.title,
                cycleType: $viewModel.cycleType,
                scheduledTime: $viewModel.scheduledTime,
                isPersistent: $viewModel.isPersistent,
                note: $viewModel.note
            )
        }
    }
}

#Preview {
    AlarmCreationView()
}
