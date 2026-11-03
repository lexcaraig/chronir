package com.chronir.designsystem.molecules

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.SpacingTokens

@Composable
fun SettingsNavigationRow(
    title: String,
    value: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onClickLabel: String? = "Open"
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = SpacingTokens.TouchMinTarget)
            .clickable(role = Role.Button, onClickLabel = onClickLabel, onClick = onClick)
            .padding(vertical = SpacingTokens.Medium),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        ChronirText(
            text = title,
            style = ChronirTextStyle.BodyPrimary,
            color = MaterialTheme.colorScheme.onSurface, // section Surface would otherwise tint it onSurfaceVariant
            modifier = Modifier.weight(1f)
        )
        Spacer(Modifier.width(SpacingTokens.Small))
        Row(verticalAlignment = Alignment.CenterVertically) {
            ChronirText(
                text = value,
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@ChronirPreview
@Composable
private fun SettingsNavigationRowPreview() {
    ChronirTheme(dynamicColor = false) {
        SettingsNavigationRow(
            title = "Alarm sound",
            value = "Default",
            onClick = {},
            modifier = Modifier.padding(horizontal = SpacingTokens.Medium)
        )
    }
}
