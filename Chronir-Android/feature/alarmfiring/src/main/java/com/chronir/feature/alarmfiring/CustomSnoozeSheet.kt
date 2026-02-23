package com.chronir.feature.alarmfiring

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Slider
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomSnoozeSheet(
    onDismiss: () -> Unit,
    onConfirm: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val sheetState = rememberModalBottomSheetState()
    var sliderValue by remember { mutableFloatStateOf(60f) }

    val minutes = sliderValue.toInt()
    val displayText = when {
        minutes < 60 -> "$minutes min"
        minutes % 60 == 0 -> "${minutes / 60}h"
        else -> "${minutes / 60}h ${minutes % 60}m"
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        modifier = modifier
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = SpacingTokens.Large)
                .padding(bottom = SpacingTokens.XXLarge),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            ChronirText(
                text = "Custom Snooze",
                style = ChronirTextStyle.TitleMedium
            )

            Spacer(Modifier.height(SpacingTokens.Large))

            ChronirText(
                text = displayText,
                style = ChronirTextStyle.HeadlineSmall,
                color = MaterialTheme.colorScheme.primary
            )

            Spacer(Modifier.height(SpacingTokens.Medium))

            Slider(
                value = sliderValue,
                onValueChange = { sliderValue = it },
                valueRange = 5f..1440f,
                steps = 0,
                modifier = Modifier.fillMaxWidth()
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                ChronirText(text = "5m", style = ChronirTextStyle.LabelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                ChronirText(text = "24h", style = ChronirTextStyle.LabelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }

            Spacer(Modifier.height(SpacingTokens.Large))

            // Quick presets
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                listOf(15 to "15m", 30 to "30m", 60 to "1h", 180 to "3h", 720 to "12h").forEach { (mins, label) ->
                    androidx.compose.material3.FilterChip(
                        selected = minutes == mins,
                        onClick = { sliderValue = mins.toFloat() },
                        label = { ChronirText(text = label, style = ChronirTextStyle.LabelSmall) }
                    )
                }
            }

            Spacer(Modifier.height(SpacingTokens.Large))

            ChronirButton(
                text = "Snooze for $displayText",
                onClick = { onConfirm(minutes) },
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
