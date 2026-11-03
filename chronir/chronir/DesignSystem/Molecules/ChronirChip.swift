import SwiftUI

/// Shape of a `ChronirChip`.
enum ChronirChipShape {
    /// Text chip (intervals, categories, pre-alarm offsets, times).
    case capsule
    /// Single-glyph chip in a grid (weekdays, days of month). Fills its grid cell.
    case circle
}

/// The one selectable chip used by every chip picker in the app.
///
/// - Hit area is at least `SpacingTokens.touchMinTarget` (44pt) tall.
/// - Selection is announced with the `.isSelected` trait (set `isToggle: false` for chips that are
///   not on/off choices, such as an added alarm time).
/// - Locked (Plus) chips show a lock glyph and announce "requires Plus" with an upgrade hint.
struct ChronirChip: View {
    let title: String
    var systemImage: String?
    var isSelected: Bool
    var isLocked: Bool
    var isToggle: Bool
    var shape: ChronirChipShape
    var tint: Color
    var selectedForeground: Color
    var accessibilityLabel: String?
    let action: () -> Void

    @ScaledMetric(relativeTo: .subheadline) private var circleDiameter = SpacingTokens.touchMinTarget - SpacingTokens.xs

    init(
        _ title: String,
        systemImage: String? = nil,
        isSelected: Bool,
        isLocked: Bool = false,
        isToggle: Bool = true,
        shape: ChronirChipShape = .capsule,
        tint: Color = ColorTokens.primary,
        selectedForeground: Color = ColorTokens.onPrimary,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.isLocked = isLocked
        self.isToggle = isToggle
        self.shape = shape
        self.tint = tint
        self.selectedForeground = selectedForeground
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label
                .foregroundStyle(isSelected ? selectedForeground : ColorTokens.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(isToggle && isSelected ? .isSelected : [])
        .accessibilityHint(isLocked ? "Opens the upgrade screen" : "")
    }

    @ViewBuilder
    private var label: some View {
        switch shape {
        case .capsule:
            HStack(spacing: SpacingTokens.xxs) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .imageScale(.small)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .imageScale(.small)
                }
                Text(title)
                    .lineLimit(1)
            }
            .chronirFont(.labelLarge)
            .padding(.horizontal, SpacingTokens.md)
            .frame(minHeight: SpacingTokens.touchMinTarget)
            .chronirGlassSelectableCapsule(isSelected: isSelected, tint: tint)
            .contentShape(Capsule())
        case .circle:
            // The visible circle stays small enough for a 7-column grid on a 375pt phone; the hit
            // area is the whole grid cell, at least 44pt tall.
            let diameter = min(circleDiameter, SpacingTokens.touchMinTarget)
            Text(title)
                .chronirFont(.labelLarge)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: diameter, height: diameter)
                .chronirGlassSelectableCircle(isSelected: isSelected, tint: tint)
                .frame(maxWidth: .infinity, minHeight: SpacingTokens.touchMinTarget)
                .contentShape(Rectangle())
        }
    }

    private var spokenLabel: String {
        let base = accessibilityLabel ?? title
        return isLocked ? "\(base), requires Plus" : base
    }
}

private struct ChronirChipGallery: View {
    @State private var selected = 1
    @State private var days: Set<Int> = [2, 4]

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            HStack(spacing: SpacingTokens.sm) {
                ChronirChip("Weekly", isSelected: selected == 1) { selected = 1 }
                ChronirChip("Monthly", isSelected: selected == 2) { selected = 2 }
                ChronirChip("1 week", isSelected: false, isLocked: true) {}
            }
            HStack(spacing: SpacingTokens.sm) {
                let finance = ChronirBadge.pair(for: .finance)
                ChronirChip(
                    "Finance",
                    systemImage: "dollarsign.circle",
                    isSelected: true,
                    tint: finance.background,
                    selectedForeground: finance.foreground
                ) {}
                ChronirChip("9:00 AM", isSelected: true, isToggle: false) {}
            }
            HStack(spacing: SpacingTokens.xs) {
                ForEach(1...7, id: \.self) { day in
                    ChronirChip(
                        "\(day)",
                        isSelected: days.contains(day),
                        shape: .circle
                    ) {
                        if days.contains(day) { days.remove(day) } else { days.insert(day) }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview("Light") {
    ChronirChipGallery()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark") {
    DarkPreview { ChronirChipGallery() }
}

#Preview("Liquid Glass") {
    GlassPreview { ChronirChipGallery() }
}
