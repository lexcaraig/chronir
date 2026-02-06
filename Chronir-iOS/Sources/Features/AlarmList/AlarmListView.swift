import SwiftUI

struct AlarmListView: View {
    @State private var viewModel = AlarmListViewModel()
    @State private var showingCreateAlarm = false
    @State private var enabledStates: [UUID: Bool] = [:]

    var body: some View {
        SingleColumnTemplate(title: "Alarms") {
            if sampleAlarms.isEmpty {
                EmptyStateView(onCreateAlarm: { showingCreateAlarm = true })
            } else {
                AlarmListSection(
                    title: "Upcoming",
                    alarms: sampleAlarms,
                    enabledStates: $enabledStates,
                    onDelete: { _ in }
                )
            }
        } floatingAction: {
            if !sampleAlarms.isEmpty {
                Button(
                    action: { showingCreateAlarm = true },
                    label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(ColorTokens.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                )
            }
        }
        .sheet(isPresented: $showingCreateAlarm) {
            AlarmCreationView()
        }
    }
}

// MARK: - Sample Data

private let sampleAlarms: [Alarm] = [
    Alarm(
        title: "Morning Workout",
        cycleType: .weekly,
        scheduledTime: Date().addingTimeInterval(3600),
        nextFireDate: Date().addingTimeInterval(3600),
        isPersistent: true,
        note: "Don't skip leg day"
    ),
    Alarm(
        title: "Pay Rent",
        cycleType: .monthly,
        scheduledTime: Date().addingTimeInterval(-7200),
        nextFireDate: Date().addingTimeInterval(-7200)
    ),
    Alarm(
        title: "Annual Checkup",
        cycleType: .yearly,
        scheduledTime: Date().addingTimeInterval(86400),
        nextFireDate: Date().addingTimeInterval(86400)
    )
]

#Preview {
    NavigationStack {
        AlarmListView()
    }
}
