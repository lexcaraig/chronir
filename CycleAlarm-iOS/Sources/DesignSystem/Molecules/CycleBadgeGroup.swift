import SwiftUI

struct CycleBadgeGroup: View {
    let badges: [(text: String, color: Color)]

    var body: some View {
        HStack(spacing: SpacingTokens.xs) {
            ForEach(Array(badges.enumerated()), id: \.offset) { _, badge in
                CycleBadge(badge.text, color: badge.color)
            }
        }
    }
}

#Preview {
    CycleBadgeGroup(badges: [
        ("Weekly", ColorTokens.primary),
        ("Persistent", ColorTokens.warning),
        ("Shared", ColorTokens.secondary)
    ])
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
