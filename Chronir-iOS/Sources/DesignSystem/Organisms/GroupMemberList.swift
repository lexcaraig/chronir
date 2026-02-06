import SwiftUI

struct GroupMemberList: View {
    let members: [UserProfile]
    let ownerID: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ChronirText("Members", style: .titleSmall, color: ColorTokens.textSecondary)

            ForEach(members) { member in
                HStack(spacing: SpacingTokens.md) {
                    Circle()
                        .fill(ColorTokens.primary)
                        .frame(width: 36, height: 36)
                        .overlay {
                            ChronirText(
                                String(member.displayName.prefix(1)).uppercased(),
                                style: .labelLarge
                            )
                        }

                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        ChronirText(member.displayName, style: .bodyMedium)
                        if member.id == ownerID {
                            ChronirBadge("Owner", color: ColorTokens.secondary)
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
