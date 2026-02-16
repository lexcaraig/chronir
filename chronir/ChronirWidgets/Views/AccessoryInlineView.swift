import SwiftUI
import WidgetKit

/// Lock screen inline widget: "bell.fill Title in 3d"
struct AccessoryInlineView: View {
    let alarm: WidgetAlarmData?

    var body: some View {
        if let alarm {
            Label {
                Text("\(alarm.title) in \(alarm.nextFireDate, style: .relative)")
            } icon: {
                Image(systemName: "bell.fill")
            }
        } else {
            Label("No alarms", systemImage: "bell.slash")
        }
    }
}
