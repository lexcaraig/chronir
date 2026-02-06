package com.cyclealarm.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.atoms.CycleBadge
import com.cyclealarm.designsystem.tokens.SpacingTokens

data class GroupMember(
    val name: String,
    val role: String
)

@Composable
fun GroupMemberList(
    members: List<GroupMember>,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
    ) {
        members.forEach { member ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = SpacingTokens.Default, vertical = SpacingTokens.Small),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = member.name,
                    style = MaterialTheme.typography.bodyLarge
                )
                CycleBadge(label = member.role)
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun GroupMemberListPreview() {
    GroupMemberList(
        members = listOf(
            GroupMember("Alice", "Owner"),
            GroupMember("Bob", "Member")
        )
    )
}
