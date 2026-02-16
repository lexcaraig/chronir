import SwiftUI
import WidgetKit

/// Lock screen rectangular widget: 2-3 alarm rows with countdowns
struct AccessoryRectangularView: View {
    let alarms: [WidgetAlarmData]

    var body: some View {
        if alarms.isEmpty {
            VStack(alignment: .leading) {
                Label("No alarms", systemImage: "bell.slash")
                    .font(.headline)
                Text("Add alarms in Chronir")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(alarms.prefix(3), id: \.id) { alarm in
                    HStack {
                        if let iconName = alarm.categoryIconName {
                            Image(systemName: iconName)
                                .font(.caption2)
                        }
                        Text(alarm.title)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        Text(alarm.nextFireDate, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}
