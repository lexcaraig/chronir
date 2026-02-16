import SwiftUI
import WidgetKit

/// Home screen small widget: next alarm with category color accent
struct SystemSmallView: View {
    let alarm: WidgetAlarmData?

    var body: some View {
        if let alarm {
            VStack(alignment: .leading, spacing: WidgetTokens.spacingSM) {
                HStack {
                    Image(systemName: alarm.categoryIconName ?? "bell.fill")
                        .font(.caption)
                        .foregroundStyle(WidgetTokens.categoryColor(for: alarm.categoryName))
                    Spacer()
                    cycleBadge(alarm.cycleType)
                }

                Text(alarm.title)
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(2)
                    .foregroundStyle(WidgetTokens.textPrimary)

                Spacer()

                Text(alarm.nextFireDate, style: .relative)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(WidgetTokens.textSecondary)

                Text(alarm.scheduleDisplayName)
                    .font(.system(.caption2))
                    .foregroundStyle(WidgetTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(WidgetTokens.spacingMD)
            .widgetURL(URL(string: "chronir://alarm/\(alarm.id.uuidString)"))
        } else {
            VStack(spacing: WidgetTokens.spacingSM) {
                Image(systemName: "bell.slash")
                    .font(.title2)
                    .foregroundStyle(WidgetTokens.textSecondary)
                Text("No alarms")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(WidgetTokens.textSecondary)
            }
            .padding(WidgetTokens.spacingMD)
        }
    }

    private func cycleBadge(_ cycleType: String) -> some View {
        Text(cycleDisplayName(cycleType))
            .font(.system(size: 9, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary)
            .clipShape(Capsule())
    }

    private func cycleDisplayName(_ raw: String) -> String {
        switch raw {
        case "weekly": return "Weekly"
        case "monthlyDate", "monthlyRelative": return "Monthly"
        case "annual": return "Annual"
        case "customDays": return "Custom"
        case "oneTime": return "One-Time"
        default: return raw.capitalized
        }
    }
}
