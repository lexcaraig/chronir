import SwiftUI
import TipKit

/// Suggests adding a widget once the user has a couple of alarms worth glancing at.
struct AddWidgetTip: Tip {
    // Module-qualified: AppIntents also defines `Parameter`.
    @TipKit.Parameter static var alarmCount: Int = 0

    var title: Text { Text("Add a Chronir widget") }
    var message: Text? { Text("See what's due next — and mark it done — right from your Home Screen.") }
    var image: Image? { Image(systemName: "square.grid.2x2") }

    var rules: [Rule] {
        #Rule(Self.$alarmCount) { $0 >= 2 }
    }
}

/// Points out pre-alarm warnings in the creation form.
struct PreAlarmTip: Tip {
    var title: Text { Text("Get a heads-up") }
    var message: Text? { Text("Pre-alarm warnings remind you days before a big deadline.") }
    var image: Image? { Image(systemName: "bell.badge") }
}
