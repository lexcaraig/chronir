package com.cyclealarm.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.tokens.SpacingTokens

@Composable
fun AlarmListSection(
    sectionTitle: String,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = SpacingTokens.Small),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
    ) {
        Text(
            text = sectionTitle,
            style = MaterialTheme.typography.titleLarge,
            modifier = Modifier.padding(horizontal = SpacingTokens.Default)
        )
        content()
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmListSectionPreview() {
    AlarmListSection(sectionTitle = "Upcoming") {
        Text("TODO: Alarm cards here")
    }
}
