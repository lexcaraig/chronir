package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ChronirBadgeGroup(
    labels: List<String>,
    modifier: Modifier = Modifier
) {
    FlowRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
        verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
    ) {
        labels.forEach { label ->
            ChronirBadge(label = label)
        }
    }
}

@ChronirThemePreview
@Composable
private fun ChronirBadgeGroupPreview() {
    ChronirTheme(dynamicColor = false) {
        ChronirBadgeGroup(labels = listOf("Weekly", "Persistent", "Shared"))
    }
}
