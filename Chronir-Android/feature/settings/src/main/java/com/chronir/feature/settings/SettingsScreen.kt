package com.chronir.feature.settings

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun SettingsScreen(
    modifier: Modifier = Modifier,
    onNavigateToCatalog: (() -> Unit)? = null
) {
    var snoozeEnabled by remember { mutableStateOf(true) }
    var slideToStopEnabled by remember { mutableStateOf(false) }

    SingleColumnTemplate(
        title = "Settings",
        modifier = modifier
    ) {
        Column(modifier = Modifier.padding(horizontal = SpacingTokens.Default)) {
            // Alarm Behavior Section
            ChronirText(
                text = "ALARM BEHAVIOR",
                style = ChronirTextStyle.LabelLarge,
                color = ColorTokens.TextSecondary,
                modifier = Modifier.padding(vertical = SpacingTokens.Small)
            )

            AlarmToggleRow(
                title = "Snooze Enabled",
                subtitle = "Allow snoozing when alarm fires",
                isEnabled = snoozeEnabled,
                onToggle = { snoozeEnabled = it }
            )

            AlarmToggleRow(
                title = "Slide to Stop",
                subtitle = "Require slide gesture to dismiss",
                isEnabled = slideToStopEnabled,
                onToggle = { slideToStopEnabled = it }
            )

            HorizontalDivider(
                modifier = Modifier.padding(vertical = SpacingTokens.Medium),
                color = ColorTokens.BorderDefault
            )

            // About Section
            ChronirText(
                text = "ABOUT",
                style = ChronirTextStyle.LabelLarge,
                color = ColorTokens.TextSecondary,
                modifier = Modifier.padding(vertical = SpacingTokens.Small)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Medium)
            ) {
                ChronirText(text = "Version", style = ChronirTextStyle.BodyPrimary)
                Spacer(Modifier.weight(1f))
                ChronirText(
                    text = "1.0.0",
                    style = ChronirTextStyle.BodySecondary,
                    color = ColorTokens.TextSecondary
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Medium)
            ) {
                ChronirText(text = "Privacy Policy", style = ChronirTextStyle.BodyPrimary)
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Medium)
            ) {
                ChronirText(text = "Terms of Service", style = ChronirTextStyle.BodyPrimary)
            }

            Spacer(Modifier.height(SpacingTokens.Large))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SettingsScreenPreview() {
    SettingsScreen()
}
