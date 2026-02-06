import SwiftUI

struct GroupMemberList: View {
    let members: [UserProfile]
    let ownerID: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            CycleText("Members", font: TypographyTokens.titleSmall, color: ColorTokens.textSecondary)

            ForEach(members) { member in
                HStack(spacing: SpacingTokens.md) {
                    Circle()
                        .fill(ColorTokens.primary)
                        .frame(width: 36, height: 36)
                        .overlay {
                            CycleText(
                                String(member.displayName.prefix(1)).uppercased(),
                                font: TypographyTokens.labelLarge
                            )
                        }

                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        CycleText(member.displayName, font: TypographyTokens.bodyMedium)
                        if member.id == ownerID {
                            CycleBadge("Owner", color: ColorTokens.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, SpacingTokens.xs)
            }
        }
    }
}

#Preview {
    GroupMemberList(
        members: [
            UserProfile(id: "1", displayName: "Alice", email: "alice@example.com"),
            UserProfile(id: "2", displayName: "Bob", email: "bob@example.com")
        ],
        ownerID: "1"
    )
    .padding()
    .background(ColorTokens.backgroundPrimary)
}
