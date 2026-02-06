import SwiftUI

struct ModalSheetTemplate<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    let onSave: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack {
            ScrollView {
                content()
            }
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .foregroundStyle(ColorTokens.primary)
                }
            }
        }
    }
}

#Preview {
    ModalSheetTemplate(
        title: "New Alarm",
        onDismiss: {},
        onSave: {}
    ) {
        Text("Form content")
            .foregroundStyle(ColorTokens.textPrimary)
            .padding()
    }
}
