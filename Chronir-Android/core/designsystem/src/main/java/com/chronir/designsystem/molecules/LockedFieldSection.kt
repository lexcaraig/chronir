package com.chronir.designsystem.molecules

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.SpacingTokens

private val LockIconSize = 14.dp // token-exempt: lock glyph matched to the 12sp label beside it

/** A Plus-only field shown read-only; tapping it opens the upgrade flow ([onClick]). */
@Composable
fun LockedFieldSection(
    label: String,
    value: String,
    placeholder: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onClickLabel: String = "Unlock with Plus"
) {
    val isEmpty = value.isBlank()
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XXSmall)
        ) {
            ChronirText(
                text = label,
                style = ChronirTextStyle.LabelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Icon(
                imageVector = Icons.Filled.Lock,
                contentDescription = "Plus feature",
                modifier = Modifier.size(LockIconSize),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Spacer(Modifier.height(SpacingTokens.XXSmall))
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = SpacingTokens.TouchMinTarget)
                .clip(MaterialTheme.shapes.medium)
                .clickable(role = Role.Button, onClickLabel = onClickLabel, onClick = onClick),
            shape = MaterialTheme.shapes.medium,
            color = MaterialTheme.colorScheme.surfaceVariant
        ) {
            ChronirText(
                text = if (isEmpty) placeholder else value,
                style = ChronirTextStyle.BodyMedium,
                color = if (isEmpty) {
                    MaterialTheme.colorScheme.onSurfaceVariant
                } else {
                    MaterialTheme.colorScheme.onSurface
                },
                modifier = Modifier.padding(SpacingTokens.Medium)
            )
        }
    }
}

@ChronirThemePreview
@Composable
private fun LockedFieldSectionPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(SpacingTokens.Medium)) {
            LockedFieldSection(label = "Notes", value = "", placeholder = "Add a note with Plus", onClick = {})
            Spacer(Modifier.height(SpacingTokens.Medium))
            LockedFieldSection(label = "Notes", value = "Bring the registration papers", placeholder = "", onClick = {})
        }
    }
}
