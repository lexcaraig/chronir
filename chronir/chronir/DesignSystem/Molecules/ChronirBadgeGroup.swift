import SwiftUI

struct ChronirBadgeGroup: View {
    let badges: [(text: String, color: Color)]

    var body: some View {
        HStack(spacing: SpacingTokens.xs) {
            ForEach(Array(badges.enumerated()), id: \.offset) { _, badge in
                ChronirBadge(badge.text, color: badge.color)
            }
        }
    }
}

#Preview {
    ChronirBadgeGroup(badges: [
        ("Weekly", ColorTokens.badgeWeekly),
        ("Persistent", ColorTokens.badgeWarning),
        ("Shared", ColorTokens.primary)
    ])
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
