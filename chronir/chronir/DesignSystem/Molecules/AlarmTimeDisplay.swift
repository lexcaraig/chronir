import SwiftUI

struct AlarmTimeDisplay: View {
    let time: Date
    var countdownText: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SpacingTokens.xs) {
            ChronirText(
                time.formatted(date: .omitted, time: .shortened),
                style: .headlineTime
            )

            if let countdown = countdownText {
                ChronirText(
                    countdown,
                    style: .captionCountdown,
                    color: ColorTokens.textSecondary
                )
            }
        }
    }
}

#Preview("With Countdown") {
    AlarmTimeDisplay(
        time: Date(),
        countdownText: "Alarm in 6h 32m"
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Time Only") {
    AlarmTimeDisplay(time: Date())
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
