package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun SettingsSection(
    header: String,
    modifier: Modifier = Modifier,
    footer: String? = null,
    content: @Composable () -> Unit
) {
    Column(modifier = modifier.fillMaxWidth()) {
        ChronirText(
            text = header.uppercase(),
            style = ChronirTextStyle.LabelLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(
                start = SpacingTokens.Medium,
                bottom = SpacingTokens.XSmall,
                top = SpacingTokens.Medium
            )
        )
        Surface(
            shape = RoundedCornerShape(RadiusTokens.Md),
            color = MaterialTheme.colorScheme.surfaceVariant,
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(horizontal = SpacingTokens.Medium)) {
                content()
            }
        }
        if (footer != null) {
            ChronirText(
                text = footer,
                style = ChronirTextStyle.BodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(
                    start = SpacingTokens.Medium,
                    top = SpacingTokens.XSmall
                )
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SettingsSectionPreview() {
    SettingsSection(
        header = "Alarm Behavior",
        footer = "These settings affect all alarms."
    ) {
        Text("Toggle rows go here", modifier = Modifier.padding(SpacingTokens.Medium))
    }
}
