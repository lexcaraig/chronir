package com.chronir.designsystem.templates

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Surface
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModalSheetTemplate(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val sheetState = rememberModalBottomSheetState()

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        modifier = modifier
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(SpacingTokens.Default)
        ) {
            content()
        }
    }
}

/** Sheet body with the same padding the template applies (ModalBottomSheet itself needs a window). */
@ChronirThemePreview
@Composable
private fun ModalSheetTemplateContentPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface(color = MaterialTheme.colorScheme.surfaceContainerLow) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Default)
            ) {
                ChronirText(text = "Custom snooze", style = ChronirTextStyle.TitleLarge)
                ChronirText(
                    text = "Pick how long to snooze this alarm.",
                    style = ChronirTextStyle.BodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
