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
