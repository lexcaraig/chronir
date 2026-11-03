// Premium shared alarms (Phase 4, Sprint 11+) is not built. `CHRONIR_PREMIUM` is never defined, so this
// scaffolding is compiled out of the shipping app (no placeholder UI in the binary). Define the flag in
// SWIFT_ACTIVE_COMPILATION_CONDITIONS when Premium work starts.
#if CHRONIR_PREMIUM
import SwiftUI

struct SharedAlarmView: View {
    @State private var viewModel = SharedAlarmViewModel()

    var body: some View {
        SingleColumnTemplate(title: "Shared Alarms") {
            Text("TODO: SharedAlarmView")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        SharedAlarmView()
    }
}
#endif
