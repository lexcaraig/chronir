package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.tokens.TypographyTokens

enum class ChronirButtonStyle {
    Primary,
    Secondary,
    Destructive,
    Ghost;

    internal val containerColor: Color
        get() = when (this) {
            Primary -> ColorTokens.AccentPrimary
            Secondary -> ColorTokens.BackgroundTertiary
            Destructive -> ColorTokens.Error
            Ghost -> Color.Transparent
        }

    internal val contentColor: Color
        get() = when (this) {
            Primary -> Color.White
            Secondary -> ColorTokens.TextPrimary
            Destructive -> Color.White
            Ghost -> ColorTokens.AccentPrimary
        }
}

@Composable
fun ChronirButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: ChronirButtonStyle = ChronirButtonStyle.Primary,
    enabled: Boolean = true
) {
    if (style == ChronirButtonStyle.Ghost) {
        TextButton(
            onClick = onClick,
            modifier = modifier.fillMaxWidth(),
            enabled = enabled,
            shape = RoundedCornerShape(RadiusTokens.Sm)
        ) {
            Text(
                text = text,
                style = TypographyTokens.LabelLarge,
                color = style.contentColor
            )
        }
    } else {
        Button(
            onClick = onClick,
            modifier = modifier.fillMaxWidth(),
            enabled = enabled,
            colors = ButtonDefaults.buttonColors(
                containerColor = style.containerColor,
                contentColor = style.contentColor
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
