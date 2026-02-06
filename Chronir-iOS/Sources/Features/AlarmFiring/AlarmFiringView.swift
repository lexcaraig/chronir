import SwiftUI

struct AlarmFiringView: View {
    @State private var viewModel = AlarmFiringViewModel()

    var body: some View {
        FullScreenAlarmTemplate {
            Text("TODO: AlarmFiringView")
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }
}

#Preview {
    AlarmFiringView()
}
