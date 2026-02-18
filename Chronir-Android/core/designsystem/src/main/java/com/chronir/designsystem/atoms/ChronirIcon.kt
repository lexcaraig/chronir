package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Alarm
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

enum class ChronirIconSize(val dp: Dp) {
    Small(16.dp),
    Medium(24.dp),
    Large(32.dp)
}

@Composable
fun ChronirIcon(
    imageVector: ImageVector,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    size: ChronirIconSize = ChronirIconSize.Medium,
    tint: Color = MaterialTheme.colorScheme.onSurface
) {
    Icon(
        imageVector = imageVector,
        contentDescription = contentDescription,
        modifier = modifier.size(size.dp),
        tint = tint
    )
}

@Preview(name = "Icon Sizes — Light", showBackground = true)
@Preview(name = "Icon Sizes — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun ChronirIconSizesPreview() {
    ChronirTheme(dynamicColor = false) {
        Row(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirIcon(Icons.Default.Alarm, "Alarm", size = ChronirIconSize.Small)
            Spacer(Modifier.width(SpacingTokens.Large))
            ChronirIcon(Icons.Default.Alarm, "Alarm", size = ChronirIconSize.Medium)
            Spacer(Modifier.width(SpacingTokens.Large))
            ChronirIcon(Icons.Default.Alarm, "Alarm", size = ChronirIconSize.Large, tint = ColorTokens.Warning)
        }
    }
}

@Preview(name = "Icon Colors", showBackground = true)
@Composable
private fun ChronirIconColorsPreview() {
    ChronirTheme(dynamicColor = false) {
        Row(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirIcon(Icons.Default.Notifications, "Bell")
            Spacer(Modifier.width(SpacingTokens.Large))
            ChronirIcon(Icons.Default.CheckCircle, "Check", tint = ColorTokens.Success)
            Spacer(Modifier.width(SpacingTokens.Large))
            ChronirIcon(Icons.Default.Warning, "Warning", tint = ColorTokens.Warning)
        }
    }
}
