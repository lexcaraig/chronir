package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.tokens.TypographyTokens

@Composable
fun ChronirBadge(
    label: String,
    modifier: Modifier = Modifier,
    containerColor: Color = ColorTokens.AccentPrimary,
    contentColor: Color = Color.White
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(RadiusTokens.Full))
            .background(containerColor)
            .padding(horizontal = SpacingTokens.Small, vertical = SpacingTokens.XSmall)
    ) {
        Text(
            text = label,
            style = TypographyTokens.LabelSmall,
            color = contentColor
        )
    }
}

@Preview(name = "Badges — Light", showBackground = true)
@Preview(name = "Badges — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun ChronirBadgeCyclePreview() {
    ChronirTheme(dynamicColor = false) {
        Row(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirBadge(label = "Weekly", containerColor = ColorTokens.BadgeWeekly)
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(label = "Monthly", containerColor = ColorTokens.BadgeMonthly)
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(label = "Yearly", containerColor = ColorTokens.BadgeAnnual)
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(label = "Custom", containerColor = ColorTokens.BadgeCustom)
        }
    }
}

@Preview(name = "Semantic Badges", showBackground = true)
@Composable
private fun ChronirBadgeSemanticPreview() {
    ChronirTheme(dynamicColor = false) {
        Row(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirBadge(label = "Active", containerColor = ColorTokens.Success)
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirBadge(label = "Persistent", containerColor = ColorTokens.Warning)
        }
    }
}
