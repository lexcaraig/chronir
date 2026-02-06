package com.chronir.designsystem.molecules

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

enum class IntervalOption(val label: String) {
    Weekly("Weekly"),
    Monthly("Monthly"),
    Yearly("Yearly")
}

@Composable
fun IntervalPicker(
    selectedOption: IntervalOption,
    onOptionSelected: (IntervalOption) -> Unit,
    modifier: Modifier = Modifier,
    options: List<IntervalOption> = IntervalOption.entries
) {
    Column(modifier = modifier) {
        ChronirText(
            text = "Repeat",
            style = ChronirTextStyle.LabelMedium,
            color = ColorTokens.TextSecondary
        )
        Row(horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)) {
            options.forEach { option ->
                val isSelected = option == selectedOption
                ChronirText(
                    text = option.label,
                    style = ChronirTextStyle.LabelLarge,
                    color = if (isSelected) Color.White else ColorTokens.TextSecondary,
                    modifier = Modifier
                        .clip(RoundedCornerShape(RadiusTokens.Sm))
                        .background(if (isSelected) ColorTokens.AccentPrimary else ColorTokens.BackgroundTertiary)
                        .clickable { onOptionSelected(option) }
                        .padding(horizontal = SpacingTokens.Medium, vertical = SpacingTokens.Small)
                )
            }
        }
    }
}

@Preview(name = "Interval Picker — Light", showBackground = true)
@Preview(name = "Interval Picker — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun IntervalPickerPreview() {
    ChronirTheme(dynamicColor = false) {
        var selected by remember { mutableStateOf(IntervalOption.Weekly) }
        IntervalPicker(
            selectedOption = selected,
            onOptionSelected = { selected = it },
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
