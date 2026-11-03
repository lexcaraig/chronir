package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.theme.chronirColors
import com.chronir.designsystem.tokens.SpacingTokens

/**
 * Outlined text field whose [label] is the field's own M3 label (so TalkBack announces it with the
 * field). [maxLength] caps input, but never silently: text past the limit is cut to the limit and
 * the field shows an error until the user edits below it. [softWarningLength] shows a non-blocking
 * warning in `chronirColors.textWarning`. A caller-owned validation error is shown by passing
 * [isError] with [supportingText]; the message is announced politely by TalkBack.
 */
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
    minLines: Int = 1,
    isError: Boolean = false,
    supportingText: String? = null
) {
    var hitLimit by remember { mutableStateOf(false) }
    val showSoftWarning = softWarningLength > 0 && value.length > softWarningLength
    val showError = hitLimit || isError
    val message = when {
        hitLimit -> "Limit is $maxLength characters"
        supportingText != null -> supportingText
        showSoftWarning -> "Titles over $softWarningLength characters may be truncated on the lock screen"
        else -> null
    }

    OutlinedTextField(
        value = value,
        onValueChange = { newValue ->
            if (maxLength > 0 && newValue.length > maxLength) {
                hitLimit = true
                onValueChange(newValue.take(maxLength))
            } else {
                hitLimit = false
                onValueChange(newValue)
            }
        },
        modifier = modifier.fillMaxWidth(),
        label = { Text(label) },
        placeholder = if (placeholder.isNotEmpty()) {
            { Text(placeholder) }
        } else {
            null
        },
        isError = showError,
        singleLine = singleLine,
        minLines = if (singleLine) 1 else minLines,
        supportingText = if (maxLength > 0 || message != null) {
            {
                Row(modifier = Modifier.fillMaxWidth()) {
                    if (message != null) {
                        Text(
                            text = message,
                            color = when {
                                showError -> MaterialTheme.colorScheme.error
                                supportingText != null -> MaterialTheme.chronirColors.textSecondary
                                else -> MaterialTheme.chronirColors.textWarning
                            },
                            modifier = Modifier
                                .weight(1f)
                                .semantics { if (showError) liveRegion = LiveRegionMode.Polite }
                        )
                        Spacer(Modifier.width(SpacingTokens.XSmall))
                    } else {
                        Spacer(Modifier.weight(1f))
                    }
                    if (maxLength > 0) {
                        Text(text = "${value.length}/$maxLength", textAlign = TextAlign.End)
                    }
                }
            }
        } else {
            null
        }
    )
}

@ChronirThemePreview
@Composable
private fun LabeledTextFieldPreview() {
    ChronirTheme(dynamicColor = false) {
        LabeledTextField(
            label = "Alarm Title",
            value = "",
            onValueChange = {},
            placeholder = "Enter alarm name",
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirThemePreview
@Composable
private fun LabeledTextFieldWithMaxLengthPreview() {
    ChronirTheme(dynamicColor = false) {
        LabeledTextField(
            label = "Alarm Title",
            value = "Renew the car registration and insurance",
            onValueChange = {},
            placeholder = "Enter alarm name",
            maxLength = 60,
            softWarningLength = 30,
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirThemePreview
@Composable
private fun LabeledTextFieldErrorPreview() {
    ChronirTheme(dynamicColor = false) {
        LabeledTextField(
            label = "Alarm Title",
            value = "",
            onValueChange = {},
            placeholder = "Enter alarm name",
            maxLength = 60,
            isError = true,
            supportingText = "Enter a name for this alarm.",
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
