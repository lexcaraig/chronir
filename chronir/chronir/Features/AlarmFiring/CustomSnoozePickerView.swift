import SwiftUI

struct CustomSnoozePickerView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    let onConfirm: (TimeInterval) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: SpacingTokens.lg) {
                ChronirText("Custom Snooze Duration", style: .headlineMedium)
                    .padding(.top, SpacingTokens.lg)

                HStack(spacing: SpacingTokens.md) {
                    VStack(spacing: SpacingTokens.xs) {
                        ChronirText("Hours", style: .labelMedium, color: ColorTokens.textSecondary)
                        Picker("Hours", selection: $hours) {
                            ForEach(0...720, id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                    }

                    VStack(spacing: SpacingTokens.xs) {
                        ChronirText("Minutes", style: .labelMedium, color: ColorTokens.textSecondary)
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0...59, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                    }
                }

                if totalSeconds > 0 {
                    ChronirText(durationLabel, style: .bodySecondary, color: ColorTokens.textSecondary)
                }

                Spacer()

                ChronirButton("Snooze", style: .primary) {
                    guard totalSeconds >= 300 else { return } // 5 min minimum
                    onConfirm(totalSeconds)
                    dismiss()
                }
                .disabled(totalSeconds < 300)
                .opacity(totalSeconds < 300 ? 0.4 : 1.0)
                .padding(.horizontal, SpacingTokens.xxxl)
                .padding(.bottom, SpacingTokens.lg)
            }
            .background(ColorTokens.backgroundPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var totalSeconds: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60)
    }

    private var durationLabel: String {
        if hours > 0 && minutes > 0 {
            return "Snooze for \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "Snooze for \(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "Snooze for \(minutes) minute\(minutes == 1 ? "" : "s")"
        }
    }
}

#Preview {
    CustomSnoozePickerView { _ in
    }
}
