import SwiftUI
import WidgetKit

/// Lock screen circular widget: countdown ring with days/hours number
struct AccessoryCircularView: View {
    let alarm: WidgetAlarmData?

    var body: some View {
        if let alarm {
            let hoursRemaining = alarm.nextFireDate.timeIntervalSinceNow / 3600
            let daysRemaining = hoursRemaining / 24
            let progress = min(max(1.0 - (hoursRemaining / (24 * 30)), 0), 1)

            Gauge(value: progress) {
                Image(systemName: "bell.fill")
            } currentValueLabel: {
                if daysRemaining >= 1 {
                    Text("\(Int(daysRemaining))d")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                } else {
                    Text("\(Int(max(hoursRemaining, 0)))h")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(WidgetTokens.accent)
        } else {
            Gauge(value: 0) {
                Image(systemName: "bell.slash")
            } currentValueLabel: {
                Text("--")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
}
