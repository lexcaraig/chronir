import SwiftUI

struct CustomSnoozePickerView: View {
    @State private var days: Int = 0
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    let onConfirm: (TimeInterval) -> Void
    @Environment(\.dismiss) private var dismiss

    private static let minimumSeconds: TimeInterval = 300
    /// Long-cycle snoozes go up to 30 days, the range the old 0–720 hour wheel covered.
    private static let maxDays = 30

    var body: some View {
        NavigationStack {
            VStack(spacing: SpacingTokens.lg) {
                HStack(spacing: SpacingTokens.xs) {
                    wheel("Days", selection: $days, range: 0...Self.maxDays)
                    wheel("Hours", selection: $hours, range: 0...23)
                    wheel("Minutes", selection: $minutes, range: 0...59)
                }
                .padding(.horizontal, SpacingTokens.md)

                ChronirText(
                    statusLabel,
                    style: .bodySecondary,
                    color: isBelowMinimum ? ColorTokens.textWarning : ColorTokens.textSecondary,
                    alignment: .center
                )
                .accessibilityAddTraits(.updatesFrequently)

                Spacer(minLength: 0)

                ChronirButton("Snooze", style: .primary) {
                    guard !isBelowMinimum else { return }
                    onConfirm(totalSeconds)
                    dismiss()
                }
                .disabled(isBelowMinimum)
                .padding(.horizontal, SpacingTokens.xxxl)
                .padding(.bottom, SpacingTokens.lg)
            }
            .padding(.top, SpacingTokens.md)
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("Custom Snooze")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func wheel(_ title: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: SpacingTokens.xs) {
            ChronirText(title, style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityHidden(true)
            Picker(title, selection: selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
    }

    private var totalSeconds: TimeInterval {
        TimeInterval(((days * 24 + hours) * 60 + minutes) * 60)
    }

    private var isBelowMinimum: Bool { totalSeconds < Self.minimumSeconds }

    private var statusLabel: String {
        if isBelowMinimum { return "Minimum snooze is 5 minutes" }
        let parts = [
            unit(days, "day"),
            unit(hours, "hour"),
            unit(minutes, "minute")
        ].compactMap { $0 }
        return "Snooze for " + parts.joined(separator: " ")
    }

    private func unit(_ value: Int, _ name: String) -> String? {
        value > 0 ? "\(value) \(name)\(value == 1 ? "" : "s")" : nil
    }
}

#Preview("Light") {
    CustomSnoozePickerView { _ in }
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CustomSnoozePickerView { _ in }
        .preferredColorScheme(.dark)
}
