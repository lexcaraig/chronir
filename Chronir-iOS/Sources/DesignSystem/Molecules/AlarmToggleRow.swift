import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AlarmToggleRow: View {
    let title: String
    let subtitle: String
    var badge: ChronirBadge?
    @Binding var isEnabled: Bool

    init(
        title: String,
        subtitle: String,
        cycleType: CycleType? = nil,
        isEnabled: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badge = cycleType.map { ChronirBadge(cycleType: $0) }
        self._isEnabled = isEnabled
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                ChronirText(title, style: .titleSmall)
                HStack(spacing: SpacingTokens.xs) {
                    if let badge {
                        badge
                    }
                    ChronirText(subtitle, style: .bodySmall, color: ColorTokens.textSecondary)
                }
            }
            Spacer()
            Toggle("", isOn: $isEnabled)
                .tint(ColorTokens.primary)
                .labelsHidden()
        }
        .padding(SpacingTokens.md)
        .onChange(of: isEnabled) {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
}

#Preview("With Cycle Badge") {
    @Previewable @State var isEnabled = true
    AlarmToggleRow(
        title: "Morning Workout",
        subtitle: "Every Monday at 6:30 AM",
        cycleType: .weekly,
        isEnabled: $isEnabled
    )
    .background(ColorTokens.surfaceCard)
}

#Preview("Without Badge") {
    @Previewable @State var isEnabled = false
    AlarmToggleRow(
        title: "Pay Rent",
        subtitle: "1st of every month",
        isEnabled: $isEnabled
    )
    .background(ColorTokens.surfaceCard)
}
