import SwiftUI
import WidgetKit

/// Home screen medium widget: 3-alarm list with countdown + badges
struct SystemMediumView: View {
    let alarms: [WidgetAlarmData]

    var body: some View {
        if alarms.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: WidgetTokens.spacingSM) {
                    Image(systemName: "bell.slash")
                        .font(.title)
                        .foregroundStyle(WidgetTokens.textSecondary)
                    Text("No upcoming alarms")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(WidgetTokens.textSecondary)
                    Text("Add alarms in Chronir")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(WidgetTokens.textSecondary)
                }
                Spacer()
            }
            .padding(WidgetTokens.spacingMD)
        } else {
            VStack(alignment: .leading, spacing: WidgetTokens.spacingXS) {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(WidgetTokens.accent)
                    Text("Upcoming Alarms")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(WidgetTokens.textSecondary)
                    Spacer()
                }

                ForEach(alarms.prefix(3), id: \.id) { alarm in
                    Link(destination: URL(string: "chronir://alarm/\(alarm.id.uuidString)")!) {
                        alarmRow(alarm)
                    }
                }

                if alarms.count > 3 {
                    Text("+\(alarms.count - 3) more")
                        .font(.system(.caption2))
                        .foregroundStyle(WidgetTokens.textSecondary)
                }
            }
            .padding(WidgetTokens.spacingMD)
        }
    }

    private func alarmRow(_ alarm: WidgetAlarmData) -> some View {
        HStack(spacing: WidgetTokens.spacingSM) {
            Circle()
                .fill(WidgetTokens.categoryColor(for: alarm.categoryName))
                .frame(width: 8, height: 8)

            Text(alarm.title)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(WidgetTokens.textPrimary)
                .lineLimit(1)

            Spacer()

            Text(alarm.nextFireDate, style: .relative)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(WidgetTokens.textSecondary)
                .lineLimit(1)
        }
    }
}
