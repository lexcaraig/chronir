import SwiftUI

struct AlarmListView: View {
    @State private var viewModel = AlarmListViewModel()

    var body: some View {
        SingleColumnTemplate(title: "Alarms") {
            Text("TODO: AlarmListView")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        AlarmListView()
    }
}
