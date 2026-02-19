package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.material3.MaterialTheme
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun ChronirToggle(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true
) {
    val haptic = LocalHapticFeedback.current
    Switch(
        checked = checked,
        onCheckedChange = { newValue ->
            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
            onCheckedChange(newValue)
        },
        modifier = modifier,
        enabled = enabled,
        colors = SwitchDefaults.colors(
            checkedTrackColor = MaterialTheme.colorScheme.primary,
            checkedThumbColor = MaterialTheme.colorScheme.onPrimary
        )
    )
}

@Preview(name = "Toggle — Light", showBackground = true)
@Preview(name = "Toggle — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun ChronirTogglePreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
            var checked by remember { mutableStateOf(true) }
            var unchecked by remember { mutableStateOf(false) }
            ChronirToggle(checked = checked, onCheckedChange = { checked = it })
            ChronirToggle(checked = unchecked, onCheckedChange = { unchecked = it })
            ChronirToggle(checked = true, onCheckedChange = {}, enabled = false)
        }
    }
}
