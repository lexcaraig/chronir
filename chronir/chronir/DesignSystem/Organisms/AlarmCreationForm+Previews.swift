import SwiftUI

private struct AlarmCreationFormPreview: View {
    @State private var title = ""
    @State private var cycleType = CycleType.weekly
    @State private var repeatInterval = 1
    @State private var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    @State private var isPersistent = true
    @State private var note = ""
    @State private var selectedDays: Set<Int> = [2]
    @State private var daysOfMonth: Set<Int> = [1]
    @State private var annualMonth = Calendar.current.component(.month, from: Date())
    @State private var annualDay = Calendar.current.component(.day, from: Date())
    @State private var annualYear = Calendar.current.component(.year, from: Date())
    @State private var startMonth = Calendar.current.component(.month, from: Date())
    @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var category: AlarmCategory?
    @State private var preAlarmOffsets: Set<PreAlarmOffset> = []
    @State private var oneTimeDate = Date()
    @State private var soundName = "alarm"
    @State private var followUpInterval = FollowUpInterval.thirtyMinutes
    var isPlusTier = true

    var body: some View {
        ScrollView {
            AlarmCreationForm(
                title: $title,
                cycleType: $cycleType,
                repeatInterval: $repeatInterval,
                timesOfDay: $timesOfDay,
                isPersistent: $isPersistent,
                note: $note,
                selectedDays: $selectedDays,
                daysOfMonth: $daysOfMonth,
                annualMonth: $annualMonth,
                annualDay: $annualDay,
                annualYear: $annualYear,
                startMonth: $startMonth,
                startYear: $startYear,
                category: $category,
                preAlarmOffsets: $preAlarmOffsets,
                oneTimeDate: $oneTimeDate,
                soundName: $soundName,
                followUpInterval: $followUpInterval,
                isPlusTier: isPlusTier
            )
        }
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview("Light — Plus") {
    AlarmCreationFormPreview()
}

#Preview("Dark — Free") {
    AlarmCreationFormPreview(isPlusTier: false)
        .environment(\.colorScheme, .dark)
}

#Preview("Liquid Glass") {
    GlassPreview { AlarmCreationFormPreview() }
}
