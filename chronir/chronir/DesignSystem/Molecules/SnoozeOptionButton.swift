import SwiftUI

/// Snooze tile on the firing screen. Uses the always-dark `firing*` tokens: the firing surface
/// never follows the app theme.
struct SnoozeOptionButton: View {
    let label: String
    let sublabel: String
    var systemImage: String?
    var accessibilityLabel: String?
    let action: () -> Void

    init(
        _ label: String,
        sublabel: String = "",
        systemImage: String? = nil,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.sublabel = sublabel
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: SpacingTokens.xxs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .chronirFont(.headlineSmall)
                        .foregroundStyle(ColorTokens.firingOnControl)
                } else {
                    ChronirText(label, style: .headlineSmall, color: ColorTokens.firingOnControl)
                }
                if !sublabel.isEmpty {
                    ChronirText(sublabel, style: .labelSmall, color: ColorTokens.firingTextSecondary)
                }
            }
            .padding(SpacingTokens.xs)
            .frame(minWidth: SpacingTokens.snoozeTileMinWidth, minHeight: SpacingTokens.snoozeTileMinHeight)
        }
        .buttonStyle(SnoozeTileStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? [label, sublabel].filter { !$0.isEmpty }.joined(separator: " "))
        .accessibilityAddTraits(.isButton)
    }
}

private struct SnoozeTileStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? ColorTokens.firingControlFillPressed : ColorTokens.firingControlFill,
                in: .rect(cornerRadius: RadiusTokens.md)
            )
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
        // At large text sizes the four tiles no longer fit one row; fall back to a 2-column grid.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SpacingTokens.md) { tiles }
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: SpacingTokens.md), GridItem(.flexible())],
                spacing: SpacingTokens.md
            ) { tiles }
        }
    }

    @ViewBuilder
    private var tiles: some View {
        SnoozeOptionButton("1", sublabel: "hour", accessibilityLabel: "Snooze 1 hour") { onSnooze(.oneHour) }
        SnoozeOptionButton("1", sublabel: "day", accessibilityLabel: "Snooze 1 day") { onSnooze(.oneDay) }
        SnoozeOptionButton("1", sublabel: "week", accessibilityLabel: "Snooze 1 week") { onSnooze(.oneWeek) }
        if showCustomButton {
            SnoozeOptionButton(
                "Custom",
                sublabel: "custom",
                systemImage: "ellipsis",
                accessibilityLabel: "Custom snooze"
            ) { onCustomTap?() }
        }
    }
}

#Preview("Snooze Option Bar") {
    SnoozeOptionBar(onSnooze: { _ in }, showCustomButton: true, onCustomTap: {})
        .padding()
        .background(ColorTokens.firingBackground)
}

#Preview("Dynamic Type") {
    SnoozeOptionBar(onSnooze: { _ in }, showCustomButton: true, onCustomTap: {})
        .padding()
        .background(ColorTokens.firingBackground)
        .dynamicTypeSize(.accessibility2)
}
