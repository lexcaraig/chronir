package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.CompletionAction

/** Completion-record status as a text badge (static color pairs that pass 4.5:1 in both themes). */
@Composable
fun CompletionStatusBadge(
    action: CompletionAction,
    modifier: Modifier = Modifier
) {
    val (label, background, foreground) = when (action) {
        CompletionAction.COMPLETED ->
            Triple("Completed", ColorTokens.BadgeSuccessBackground, ColorTokens.BadgeSuccessForeground)
        CompletionAction.SNOOZED ->
            Triple("Snoozed", ColorTokens.BadgeWarningBackground, ColorTokens.BadgeWarningForeground)
        CompletionAction.MISSED ->
            Triple("Missed", ColorTokens.BadgeErrorBackground, ColorTokens.BadgeErrorForeground)
        CompletionAction.SKIPPED ->
            Triple("Skipped", ColorTokens.BadgeNeutralBackground, ColorTokens.BadgeNeutralForeground)
        CompletionAction.PENDING_CONFIRMATION ->
            Triple("Pending", ColorTokens.BadgePendingBackground, ColorTokens.BadgePendingForeground)
    }
    ChronirBadge(label = label, containerColor = background, contentColor = foreground, modifier = modifier)
}

@OptIn(ExperimentalLayoutApi::class)
@ChronirThemePreview
@Composable
private fun CompletionStatusBadgePreview() {
    ChronirTheme(dynamicColor = false) {
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall),
            modifier = Modifier.padding(SpacingTokens.Medium)
        ) {
            CompletionAction.entries.forEach { CompletionStatusBadge(action = it) }
        }
    }
}
