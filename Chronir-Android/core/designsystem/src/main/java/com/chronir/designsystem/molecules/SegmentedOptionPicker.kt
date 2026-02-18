package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.material3.MaterialTheme
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <T> SegmentedOptionPicker(
    label: String,
    options: List<T>,
    selected: T,
    onSelect: (T) -> Unit,
    labelMapper: (T) -> String,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth().padding(horizontal = SpacingTokens.Medium)) {
        ChronirText(
            text = label,
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(bottom = SpacingTokens.XSmall)
        )
        SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
            options.forEachIndexed { index, option ->
                SegmentedButton(
                    selected = option == selected,
                    onClick = { onSelect(option) },
                    shape = SegmentedButtonDefaults.itemShape(index = index, count = options.size)
                ) {
                    Text(labelMapper(option))
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SegmentedOptionPickerPreview() {
    SegmentedOptionPicker(
        label = "Theme",
        options = listOf("Light", "Dark", "Dynamic"),
        selected = "Dynamic",
        onSelect = {},
        labelMapper = { it }
    )
}
