package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
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
        // Material section header: sentence case, titleSmall in primary, a TalkBack heading.
        ChronirText(
            text = header,
            style = ChronirTextStyle.TitleSmall,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier
                .padding(
                    start = SpacingTokens.Medium,
                    bottom = SpacingTokens.XSmall,
                    top = SpacingTokens.Large
                )
                .semantics { heading() }
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

@ChronirThemePreview
@Composable
private fun SettingsSectionPreview() {
    ChronirTheme(dynamicColor = false) {
        SettingsSection(
            header = "Alarm behavior",
            footer = "These settings affect all alarms.",
            modifier = Modifier.padding(SpacingTokens.Medium)
        ) {
            AlarmToggleRow(title = "Snooze", subtitle = "Allow snoozing when an alarm fires", isEnabled = true, onToggle = {})
            SettingsNavigationRow(title = "Alarm sound", value = "Default", onClick = {})
        }
    }
}
