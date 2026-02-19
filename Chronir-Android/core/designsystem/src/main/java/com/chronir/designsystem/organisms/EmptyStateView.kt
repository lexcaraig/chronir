package com.chronir.designsystem.organisms

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.NotificationsOff
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.material3.MaterialTheme
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun EmptyStateView(
    onCreateAlarm: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(SpacingTokens.Large),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Outlined.NotificationsOff,
            contentDescription = "No alarms",
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(Modifier.height(SpacingTokens.Large))

        ChronirText(
            text = "No alarms yet",
            style = ChronirTextStyle.HeadlineTitle
        )

        Spacer(Modifier.height(SpacingTokens.Small))

        ChronirText(
            text = "Set recurring alarms that fire weekly, monthly, or yearly.",
            style = ChronirTextStyle.BodySecondary,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )

        Spacer(Modifier.height(SpacingTokens.Large))

        ChronirButton(
            text = "Create First Alarm",
            onClick = onCreateAlarm,
            modifier = Modifier.padding(horizontal = SpacingTokens.XXLarge)
        )
    }
}

@ChronirPreview
@Composable
private fun EmptyStateViewPreview() {
    ChronirTheme(dynamicColor = false) {
        EmptyStateView(onCreateAlarm = {})
    }
}
