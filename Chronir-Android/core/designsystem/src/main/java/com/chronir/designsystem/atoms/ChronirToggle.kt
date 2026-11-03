package com.chronir.designsystem.atoms

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.theme.chronirHapticFeedback
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun ChronirToggle(
    checked: Boolean,
    onCheckedChange: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    enabled: Boolean = true
) {
    val haptic = chronirHapticFeedback()
    Switch(
        checked = checked,
        // Null when a parent row owns the toggle (Modifier.toggleable) so the row + label is one node.
        onCheckedChange = onCheckedChange?.let { onChange ->
            { newValue: Boolean ->
                // Light tick, not the heavy LongPress buzz (ToggleOn/Off needs Compose 1.8).
                haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                onChange(newValue)
            }
        },
        modifier = modifier,
        enabled = enabled,
        colors = SwitchDefaults.colors(
            checkedTrackColor = MaterialTheme.colorScheme.primary,
            checkedThumbColor = MaterialTheme.colorScheme.onPrimary
        )
    )
}

@ChronirThemePreview
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
