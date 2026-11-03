import SwiftUI

struct ModalSheetTemplate<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    let onSave: () -> Void
    /// When true, Cancel asks before discarding and swipe-to-dismiss is blocked (HIG: guard data loss).
    var hasUnsavedChanges: Bool
    var isSaveDisabled: Bool
    var discardTitle: String
    @ViewBuilder let content: () -> Content

    @State private var isConfirmingDiscard = false

    init(
        title: String,
        onDismiss: @escaping () -> Void,
        onSave: @escaping () -> Void,
        hasUnsavedChanges: Bool = false,
        isSaveDisabled: Bool = false,
        discardTitle: String = "Discard Changes?",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.onDismiss = onDismiss
        self.onSave = onSave
        self.hasUnsavedChanges = hasUnsavedChanges
        self.isSaveDisabled = isSaveDisabled
        self.discardTitle = discardTitle
        self.content = content
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                content()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .confirmationDialog(
                            discardTitle,
                            isPresented: $isConfirmingDiscard,
                            titleVisibility: .visible
                        ) {
                            Button("Discard Changes", role: .destructive, action: onDismiss)
                            Button("Keep Editing", role: .cancel) {}
                        }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .foregroundStyle(isSaveDisabled ? ColorTokens.textSecondary : ColorTokens.primary)
                        .disabled(isSaveDisabled)
                }
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
    }

    private func cancel() {
        if hasUnsavedChanges {
            isConfirmingDiscard = true
        } else {
            onDismiss()
        }
    }
}

#Preview("Light") {
    ModalSheetTemplate(
        title: "New Alarm",
        onDismiss: {},
        onSave: {},
        hasUnsavedChanges: true,
        content: {
            Text("Form content")
                .foregroundStyle(ColorTokens.textPrimary)
                .padding()
        }
    )
}

#Preview("Dark") {
    ModalSheetTemplate(
        title: "New Alarm",
        onDismiss: {},
        onSave: {},
        isSaveDisabled: true,
        content: {
            Text("Form content")
                .foregroundStyle(ColorTokens.textPrimary)
                .padding()
        }
    )
    .environment(\.colorScheme, .dark)
}
