package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun LabeledTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    maxLength: Int = 0,
    softWarningLength: Int = 0,
    singleLine: Boolean = true,
    minLines: Int = 1
) {
    Column(modifier = modifier) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            modifier = Modifier.padding(bottom = SpacingTokens.XSmall)
        )
        OutlinedTextField(
            value = value,
            onValueChange = { newValue ->
                if (maxLength > 0 && newValue.length > maxLength) return@OutlinedTextField
                onValueChange(newValue)
            },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text(placeholder) },
            singleLine = singleLine,
            minLines = if (singleLine) 1 else minLines
        )
        if (maxLength > 0) {
            Text(
                text = "${value.length}/$maxLength",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier
                    .align(Alignment.End)
                    .padding(top = SpacingTokens.XXSmall)
            )
        }
        if (softWarningLength > 0 && value.length > softWarningLength) {
            Text(
                text = "Titles over $softWarningLength characters may be truncated on the lock screen",
                style = MaterialTheme.typography.labelSmall,
                color = ColorTokens.Warning,
                modifier = Modifier.padding(top = SpacingTokens.XXSmall)
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun LabeledTextFieldPreview() {
    LabeledTextField(
        label = "Alarm Title",
        value = "",
        onValueChange = {},
        placeholder = "Enter alarm name"
    )
}

@Preview(showBackground = true)
@Composable
private fun LabeledTextFieldWithMaxLengthPreview() {
    LabeledTextField(
        label = "Alarm Title",
        value = "Morning Workout",
        onValueChange = {},
        placeholder = "Enter alarm name",
        maxLength = 60
    )
}
