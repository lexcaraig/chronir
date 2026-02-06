package com.cyclealarm.designsystem.molecules

import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview

@Composable
fun SnoozeOptionButton(
    minutes: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    FilledTonalButton(
        onClick = onClick,
        modifier = modifier
    ) {
        Text(text = "$minutes min")
    }
}

@Preview(showBackground = true)
@Composable
private fun SnoozeOptionButtonPreview() {
    SnoozeOptionButton(minutes = 5, onClick = {})
}
