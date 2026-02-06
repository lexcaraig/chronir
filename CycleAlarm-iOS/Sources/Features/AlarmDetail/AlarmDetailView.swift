import SwiftUI

struct AlarmDetailView: View {
    let alarmID: UUID
    @State private var viewModel = AlarmDetailViewModel()

    var body: some View {
        SingleColumnTemplate(title: "Alarm Detail") {
            Text("TODO: AlarmDetailView")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        AlarmDetailView(alarmID: UUID())
    }
}
