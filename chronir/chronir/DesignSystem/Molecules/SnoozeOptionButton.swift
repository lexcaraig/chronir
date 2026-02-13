import SwiftUI

struct SnoozeOptionButton: View {
    let label: String
    let sublabel: String
    let action: () -> Void

    init(_ label: String, sublabel: String = "", action: @escaping () -> Void) {
        self.label = label
        self.sublabel = sublabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: SpacingTokens.xxs) {
                ChronirText(label, style: .headlineSmall)
                if !sublabel.isEmpty {
                    ChronirText(sublabel, style: .labelSmall, color: ColorTokens.textSecondary)
                }
            }
            .frame(width: 72, height: 64)
            .background(ColorTokens.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
        }
    }
}

struct SnoozeOptionBar: View {
    let onSnooze: (SnoozeInterval) -> Void

    enum SnoozeInterval {
        case oneHour
        case oneDay
        case oneWeek
        case custom(TimeInterval)
    }

    var showCustomButton: Bool = false
    var onCustomTap: (() -> Void)?

    var body: some View {
        HStack(spacing: SpacingTokens.md) {
            SnoozeOptionButton("1", sublabel: "hour") { onSnooze(.oneHour) }
            SnoozeOptionButton("1", sublabel: "day") { onSnooze(.oneDay) }
            SnoozeOptionButton("1", sublabel: "week") { onSnooze(.oneWeek) }
            if showCustomButton {
                SnoozeOptionButton("...", sublabel: "custom") { onCustomTap?() }
            }
        }
    }
}

#Preview("Snooze Option Bar") {
    SnoozeOptionBar(onSnooze: { _ in })
        .padding()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Individual Button") {
    SnoozeOptionButton("5", sublabel: "min") {}
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
