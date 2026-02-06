package com.chronir.feature.alarmfiring

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview

@Composable
fun AlarmFiringScreen(
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text("TODO: AlarmFiringScreen")
    }
}

@Preview(showBackground = true)
@Composable
private fun AlarmFiringScreenPreview() {
    AlarmFiringScreen()
}
