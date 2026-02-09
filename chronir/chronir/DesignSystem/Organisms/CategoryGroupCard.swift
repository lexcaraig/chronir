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
                ChronirText(
                    category.displayName,
                    style: .titleMedium,
                    color: ColorTokens.textPrimary
                )
                ChronirBadge("\(alarms.count)", color: category.color)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(ColorTokens.textSecondary)
                    .font(.caption.weight(.semibold))
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
        .background(ColorTokens.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
    }

    private func compactRow(_ alarm: Alarm) -> some View {
        let isEnabled = enabledStates[alarm.id] ?? alarm.isEnabled
        return HStack(spacing: SpacingTokens.sm) {
            Circle()
                .fill(isEnabled ? ColorTokens.success : ColorTokens.textDisabled)
                .frame(width: 6, height: 6)
            ChronirText(
                alarm.title,
                style: .bodyMedium,
                color: isEnabled ? ColorTokens.textPrimary : ColorTokens.textDisabled
            )
            Spacer()
            ChronirText(
                alarm.nextFireDate.formatted(.dateTime.month(.abbreviated).day()),
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
