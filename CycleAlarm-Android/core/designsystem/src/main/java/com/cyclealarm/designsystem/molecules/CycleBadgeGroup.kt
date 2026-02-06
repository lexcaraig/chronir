package com.cyclealarm.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.cyclealarm.designsystem.atoms.CycleBadge
import com.cyclealarm.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun CycleBadgeGroup(
    labels: List<String>,
    modifier: Modifier = Modifier
) {
    FlowRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
    ) {
        labels.forEach { label ->
            CycleBadge(label = label)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun CycleBadgeGroupPreview() {
    CycleBadgeGroup(labels = listOf("Weekly", "Persistent", "Shared"))
}
