package com.chronir.designsystem.molecules

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens

private val SnoozeTileMinWidth = 72.dp // token-exempt: firing-spec snooze tile minimum; grows with font
private val SnoozeTileMinHeight = 64.dp // token-exempt: firing-spec snooze tile minimum; grows with font

/**
 * Tonal snooze tile ("1" over "hour"). Minimum size, not a fixed size, so the labels never clip at
 * large font. TalkBack reads it as one button: "Snooze 1 hour".
 */
@Composable
fun SnoozeOptionButton(
    label: String,
    sublabel: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    containerColor: Color = MaterialTheme.colorScheme.secondaryContainer,
    contentColor: Color = MaterialTheme.colorScheme.onSecondaryContainer,
    accessibilityLabel: String = "Snooze $label $sublabel"
) {
    FilledTonalButton(
        onClick = onClick,
        modifier = modifier
            .defaultMinSize(minWidth = SnoozeTileMinWidth, minHeight = SnoozeTileMinHeight)
            .clearAndSetSemantics {
                role = Role.Button
                contentDescription = accessibilityLabel
                onClick {
                    onClick()
                    true
                }
            },
        shape = RoundedCornerShape(RadiusTokens.Md),
        colors = ButtonDefaults.filledTonalButtonColors(
            containerColor = containerColor,
            contentColor = contentColor
        ),
        contentPadding = PaddingValues(horizontal = SpacingTokens.XSmall, vertical = SpacingTokens.XSmall)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            ChronirText(text = label, style = ChronirTextStyle.HeadlineSmall, color = contentColor)
            ChronirText(text = sublabel, style = ChronirTextStyle.LabelSmall, color = contentColor)
        }
    }
}

enum class SnoozeInterval {
    OneHour,
    OneDay,
    OneWeek
}

/** Three snooze tiles sharing the row width equally (each at least 72 x 64dp). */
@Composable
fun SnoozeOptionBar(
    onSnooze: (SnoozeInterval) -> Unit,
    modifier: Modifier = Modifier,
    containerColor: Color = MaterialTheme.colorScheme.secondaryContainer,
    contentColor: Color = MaterialTheme.colorScheme.onSecondaryContainer
) {
    val options = listOf(
        Triple("1", "hour", SnoozeInterval.OneHour),
        Triple("1", "day", SnoozeInterval.OneDay),
        Triple("1", "week", SnoozeInterval.OneWeek)
    )
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small, Alignment.CenterHorizontally)
    ) {
        options.forEach { (label, sublabel, interval) ->
            SnoozeOptionButton(
                label = label,
                sublabel = sublabel,
                onClick = { onSnooze(interval) },
                modifier = Modifier.weight(1f),
                containerColor = containerColor,
                contentColor = contentColor
            )
        }
    }
}

@ChronirPreview
@Composable
private fun SnoozeOptionBarPreview() {
    ChronirTheme(dynamicColor = false) {
        SnoozeOptionBar(
            onSnooze = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun SnoozeOptionBarFiringPreview() {
    ChronirTheme(dynamicColor = false) {
        SnoozeOptionBar(
            onSnooze = {},
            modifier = Modifier
                .background(ColorTokens.FiringBackground)
                .padding(SpacingTokens.Medium),
            containerColor = ColorTokens.FiringControlFill,
            contentColor = ColorTokens.FiringOnControl
        )
    }
}
