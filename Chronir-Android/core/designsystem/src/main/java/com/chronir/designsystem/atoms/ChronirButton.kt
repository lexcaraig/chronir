package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.tokens.TypographyTokens

enum class ChronirButtonStyle {
    Primary,
    Secondary,
    Destructive,
    Ghost
}

@Composable
fun ChronirButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: ChronirButtonStyle = ChronirButtonStyle.Primary,
    enabled: Boolean = true
) {
    val containerColor = when (style) {
        ChronirButtonStyle.Primary -> MaterialTheme.colorScheme.primary
        ChronirButtonStyle.Secondary -> MaterialTheme.colorScheme.surfaceVariant
        ChronirButtonStyle.Destructive -> ColorTokens.Error
        ChronirButtonStyle.Ghost -> Color.Transparent
    }

    val contentColor = when (style) {
        ChronirButtonStyle.Primary -> MaterialTheme.colorScheme.onPrimary
        ChronirButtonStyle.Secondary -> MaterialTheme.colorScheme.onSurface
        ChronirButtonStyle.Destructive -> Color.White
        ChronirButtonStyle.Ghost -> MaterialTheme.colorScheme.primary
    }

    if (style == ChronirButtonStyle.Ghost) {
        OutlinedButton(
            onClick = onClick,
            modifier = modifier.fillMaxWidth(),
            enabled = enabled,
            shape = RoundedCornerShape(RadiusTokens.Sm),
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary),
            colors = ButtonDefaults.outlinedButtonColors(
                contentColor = contentColor
            )
        ) {
            Text(
                text = text,
                style = TypographyTokens.LabelLarge,
                color = contentColor
            )
        }
    } else {
        Button(
            onClick = onClick,
            modifier = modifier.fillMaxWidth(),
            enabled = enabled,
            colors = ButtonDefaults.buttonColors(
                containerColor = containerColor,
                contentColor = contentColor
            ),
            shape = RoundedCornerShape(RadiusTokens.Sm)
        ) {
            Text(
                text = text,
                style = TypographyTokens.LabelLarge
            )
        }
    }
}

@Preview(name = "Buttons — Light", showBackground = true)
@Preview(name = "Buttons — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun ChronirButtonPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
            ChronirButton(text = "Primary Action", onClick = {})
            ChronirButton(text = "Secondary", onClick = {}, style = ChronirButtonStyle.Secondary)
            ChronirButton(text = "Delete", onClick = {}, style = ChronirButtonStyle.Destructive)
            ChronirButton(text = "Ghost Action", onClick = {}, style = ChronirButtonStyle.Ghost)
        }
    }
}
