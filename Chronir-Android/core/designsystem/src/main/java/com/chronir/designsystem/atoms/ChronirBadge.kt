package com.chronir.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun ChronirBadge(
    label: String,
    modifier: Modifier = Modifier,
    containerColor: Color = MaterialTheme.colorScheme.primaryContainer,
    contentColor: Color = MaterialTheme.colorScheme.onPrimaryContainer
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(RadiusTokens.Full))
            .background(containerColor)
            .padding(horizontal = SpacingTokens.Small, vertical = SpacingTokens.XSmall)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = contentColor
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun ChronirBadgePreview() {
    ChronirBadge(label = "Weekly")
}
