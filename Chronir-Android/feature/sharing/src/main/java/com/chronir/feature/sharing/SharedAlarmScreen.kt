package com.chronir.feature.sharing

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview

@Composable
fun SharedAlarmScreen(
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text("TODO: SharedAlarmScreen")
    }
}

@Preview(showBackground = true)
@Composable
private fun SharedAlarmScreenPreview() {
    SharedAlarmScreen()
}
