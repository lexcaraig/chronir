import SwiftUI

struct CategoryGroupCard: View {
    let category: AlarmCategory
    let alarms: [Alarm]
    let enabledStates: [UUID: Bool]

    private var displayedAlarms: [Alarm] {
        Array(alarms.prefix(3))
    }

    private var overflowCount: Int {
        max(alarms.count - 3, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            // Header: icon + name + count + chevron
            HStack(spacing: SpacingTokens.sm) {
                Image(systemName: category.iconName)
                    .foregroundStyle(category.color)
                    .font(.title3)
                    .accessibilityHidden(true)
                ChronirText(
                    category.displayName,
                    style: .titleMedium,
                    color: ColorTokens.textPrimary
                )
                ChronirBadge("\(alarms.count)", category: category)
                    .accessibilityLabel(alarms.count == 1 ? "1 alarm" : "\(alarms.count) alarms")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(ColorTokens.textSecondary)
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }

            // Compact alarm rows
            ForEach(displayedAlarms) { alarm in
                compactRow(alarm)
            }

            if overflowCount > 0 {
                ChronirText(
                    "+\(overflowCount) more",
                    style: .labelLarge,
                    color: ColorTokens.textSecondary
                )
            }
        }
        .padding(SpacingTokens.cardPadding)
        .chronirGlassCard()
        // The whole card opens the category (chevron) and has no inner controls.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Shows all \(category.displayName) alarms")
    }

    private func compactRow(_ alarm: Alarm) -> some View {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        return HStack(spacing: SpacingTokens.sm) {
            // Shape + text, not color alone: a filled dot for on, a hollow ring plus "Off" for off.
            Image(systemName: isEnabled ? "circle.fill" : "circle")
                .imageScale(.small)
                .font(.caption2)
                .foregroundStyle(isEnabled ? ColorTokens.success : ColorTokens.textSecondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                ChronirText(
                    alarm.title,
                    style: .bodyMedium,
                    color: isEnabled ? ColorTokens.textPrimary : ColorTokens.textSecondary
                )
                ChronirText(
                    isEnabled ? alarm.schedule.displayName : "\(alarm.schedule.displayName) · Off",
                    style: .caption,
                    color: ColorTokens.textSecondary
                )
            }
            Spacer()
            ChronirText(
                alarm.nextFireDate.formatted(.dateTime.month(.abbreviated).day().hour().minute()),
                style: .labelSmall,
                color: ColorTokens.textSecondary
            )
        }
    }
}

// MARK: - Preview Helpers

private extension CategoryGroupCard {
    static var sampleAlarms: [Alarm] {
        [
            Alarm(title: "Pay Rent", cycleType: .monthlyDate, category: "finance"),
            Alarm(title: "Credit Card Bill", cycleType: .monthlyDate, category: "finance")
        ]
    }

    static var manySampleAlarms: [Alarm] {
        [
            Alarm(title: "Pay Rent", cycleType: .monthlyDate, category: "finance"),
            Alarm(title: "Credit Card Bill", cycleType: .monthlyDate, category: "finance"),
            Alarm(title: "Insurance Premium", cycleType: .monthlyDate, category: "finance"),
            Alarm(title: "Phone Bill", cycleType: .monthlyDate, category: "finance"),
            Alarm(title: "Internet Bill", cycleType: .monthlyDate, category: "finance")
        ]
    }
}

#Preview("2 Alarms") {
    CategoryGroupCard(
        category: .finance,
        alarms: CategoryGroupCard.sampleAlarms,
        enabledStates: [:]
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("5 Alarms") {
    CategoryGroupCard(
        category: .finance,
        alarms: CategoryGroupCard.manySampleAlarms,
        enabledStates: [:]
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark Mode") {
    DarkPreview {
        VStack(spacing: SpacingTokens.md) {
            CategoryGroupCard(
                category: .health,
                alarms: CategoryGroupCard.sampleAlarms,
                enabledStates: [:]
            )
            CategoryGroupCard(
                category: .finance,
                alarms: CategoryGroupCard.manySampleAlarms,
                enabledStates: [:]
            )
        }
        .padding()
    }
}

#Preview("Liquid Glass") {
    GlassPreview {
        CategoryGroupCard(
            category: .vehicle,
            alarms: CategoryGroupCard.sampleAlarms,
            enabledStates: [:]
        )
        .padding()
    }
}
