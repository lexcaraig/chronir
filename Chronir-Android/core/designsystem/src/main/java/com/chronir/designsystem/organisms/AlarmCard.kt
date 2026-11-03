package com.chronir.designsystem.organisms

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.atoms.ChronirToggle
import com.chronir.designsystem.molecules.AlarmTimeDisplay
import com.chronir.designsystem.theme.ChronirDynamicPreview
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.util.rememberTimeFormatter
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import com.chronir.model.countdownText
import java.time.Instant
import java.time.LocalTime

enum class AlarmVisualState {
    Active,
    Inactive,
    Snoozed,
    Overdue,
    Pending;

    /** Card border (non-text accent; always paired with a text badge so state is never color-only). */
    val accentColor: Color?
        get() = when (this) {
            Active -> null
            Inactive -> null
            Snoozed -> ColorTokens.Warning
            Overdue -> ColorTokens.Error
            Pending -> ColorTokens.PendingOrange
        }

    val statusBadgeLabel: String?
        get() = when (this) {
            Active -> null
            Inactive -> null
            Snoozed -> "Snoozed"
            Overdue -> "Missed"
            Pending -> "Pending"
        }

    val statusBadgeColor: Color
        get() = when (this) {
            Snoozed -> ColorTokens.BadgeWarningBackground
            Overdue -> ColorTokens.BadgeErrorBackground
            Pending -> ColorTokens.BadgePendingBackground
            else -> Color.Transparent
        }

    val statusBadgeContentColor: Color
        get() = when (this) {
            Snoozed -> ColorTokens.BadgeWarningForeground
            Overdue -> ColorTokens.BadgeErrorForeground
            Pending -> ColorTokens.BadgePendingForeground
            else -> Color.Unspecified
        }
}

/** Cycle badge label + token pair, shared by AlarmCard and AlarmFiringView. */
internal fun cycleTypeLabel(cycleType: CycleType): String = when (cycleType) {
    CycleType.ONE_TIME -> "One-Time"
    CycleType.WEEKLY -> "Weekly"
    CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> "Monthly"
    CycleType.ANNUAL -> "Annual"
    CycleType.CUSTOM_DAYS -> "Custom"
}

internal fun cycleTypeBadgeBackground(cycleType: CycleType): Color = when (cycleType) {
    CycleType.ONE_TIME -> ColorTokens.BadgeOneTimeBackground
    CycleType.WEEKLY -> ColorTokens.BadgeWeeklyBackground
    CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> ColorTokens.BadgeMonthlyBackground
    CycleType.ANNUAL -> ColorTokens.BadgeAnnualBackground
    CycleType.CUSTOM_DAYS -> ColorTokens.BadgeCustomBackground
}

internal fun cycleTypeBadgeForeground(cycleType: CycleType): Color = when (cycleType) {
    CycleType.ONE_TIME -> ColorTokens.BadgeOneTimeForeground
    CycleType.WEEKLY -> ColorTokens.BadgeWeeklyForeground
    CycleType.MONTHLY_DATE, CycleType.MONTHLY_RELATIVE -> ColorTokens.BadgeMonthlyForeground
    CycleType.ANNUAL -> ColorTokens.BadgeAnnualForeground
    CycleType.CUSTOM_DAYS -> ColorTokens.BadgeCustomForeground
}

/**
 * Alarm row card. When [onDelete] is set the card supports swipe-to-delete (end-to-start, with an
 * errorContainer + trash reveal) and exposes a "Delete" accessibility action. The screen hosting
 * the card owns the "Alarm deleted · Undo" snackbar.
 */
@Composable
fun AlarmCard(
    alarm: Alarm,
    visualState: AlarmVisualState,
    isEnabled: Boolean,
    onToggle: (Boolean) -> Unit,
    onClick: () -> Unit,
    onDelete: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val isInactive = visualState == AlarmVisualState.Inactive
    // One de-emphasis mechanism for inactive alarms: onSurfaceVariant at full opacity (>= 4.5:1).
    val primaryTextColor = if (isInactive) {
        MaterialTheme.colorScheme.onSurfaceVariant
    } else {
        MaterialTheme.colorScheme.onSurface
    }
    val deleteActions = onDelete?.let { delete ->
        listOf(
            CustomAccessibilityAction(label = "Delete alarm") {
                delete()
                true
            }
        )
    }

    val cardContent: @Composable () -> Unit = {
        Card(
            onClick = onClick,
            modifier = modifier
                .fillMaxWidth()
                .semantics {
                    onClick(label = "Open alarm details") {
                        onClick()
                        true
                    }
                    if (deleteActions != null) customActions = deleteActions
                },
            shape = RoundedCornerShape(RadiusTokens.Md),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
            border = visualState.accentColor?.let { BorderStroke(2.dp, it) } // token-exempt: status stroke
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(SpacingTokens.Large)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        ChronirText(
                            text = alarm.title,
                            style = ChronirTextStyle.TitleMedium,
                            color = primaryTextColor
                        )
                        Spacer(Modifier.height(SpacingTokens.XXSmall))
                        Row {
                            ChronirBadge(
                                label = cycleTypeLabel(alarm.cycleType),
                                containerColor = cycleTypeBadgeBackground(alarm.cycleType),
                                contentColor = cycleTypeBadgeForeground(alarm.cycleType)
                            )
                            visualState.statusBadgeLabel?.let { label ->
                                Spacer(Modifier.width(SpacingTokens.XSmall))
                                ChronirBadge(
                                    label = label,
                                    containerColor = visualState.statusBadgeColor,
                                    contentColor = visualState.statusBadgeContentColor
                                )
                            }
                        }
                    }
                    ChronirToggle(
                        checked = isEnabled,
                        onCheckedChange = onToggle,
                        // The card itself opens details, so the switch is its own labelled node.
                        modifier = Modifier.semantics { contentDescription = "${alarm.title} alarm" }
                    )
                }

                Spacer(Modifier.height(SpacingTokens.Small))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val timeFormatter = rememberTimeFormatter()
                    if (!isInactive) {
                        AlarmTimeDisplay(
                            timeText = alarm.timeOfDay.format(timeFormatter),
                            countdownText = if (visualState == AlarmVisualState.Active) countdownText(alarm.nextFireDate) else null
                        )
                    } else {
                        ChronirText(
                            text = alarm.timeOfDay.format(timeFormatter),
                            style = ChronirTextStyle.HeadlineTime,
                            color = primaryTextColor
                        )
                    }
                    Spacer(Modifier.weight(1f))
                    if (alarm.isPersistent) {
                        ChronirBadge(
                            label = "Persistent",
                            containerColor = ColorTokens.BadgeWarningBackground,
                            contentColor = ColorTokens.BadgeWarningForeground
                        )
                    }
                }
            }
        }
    }

    if (onDelete != null) {
        val dismissState = rememberSwipeToDismissBoxState(
            confirmValueChange = { value ->
                if (value == SwipeToDismissBoxValue.EndToStart) {
                    onDelete()
                    true
                } else {
                    false
                }
            }
        )
        SwipeToDismissBox(
            state = dismissState,
            backgroundContent = { SwipeDeleteBackground(modifier = modifier) },
            enableDismissFromStartToEnd = false
        ) {
            cardContent()
        }
    } else {
        cardContent()
    }
}

/** Revealed under the card while swiping: errorContainer plate with a trailing trash icon. */
@Composable
private fun SwipeDeleteBackground(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .clip(RoundedCornerShape(RadiusTokens.Md))
            .background(MaterialTheme.colorScheme.errorContainer)
            .padding(horizontal = SpacingTokens.Large),
        contentAlignment = Alignment.CenterEnd
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            ChronirText(
                text = "Delete",
                style = ChronirTextStyle.LabelLarge,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
            Spacer(Modifier.width(SpacingTokens.XSmall))
            Icon(
                imageVector = Icons.Outlined.Delete,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onErrorContainer
            )
        }
    }
}

// MARK: - Previews

private val sampleAlarm = Alarm(
    title = "Morning Workout",
    cycleType = CycleType.WEEKLY,
    timeOfDay = LocalTime.of(7, 0),
    schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
    nextFireDate = Instant.now(),
    persistenceLevel = PersistenceLevel.FULL
)

private val sampleAlarmMonthly = Alarm(
    title = "Pay Rent",
    cycleType = CycleType.MONTHLY_DATE,
    timeOfDay = LocalTime.of(9, 0),
    schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
    nextFireDate = Instant.now()
)

@ChronirPreview
@Composable
private fun AlarmCardActivePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarm,
            visualState = AlarmVisualState.Active,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardInactivePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarmMonthly,
            visualState = AlarmVisualState.Inactive,
            isEnabled = false,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardSnoozedPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarm,
            visualState = AlarmVisualState.Snoozed,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmCardOverduePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarmMonthly,
            visualState = AlarmVisualState.Overdue,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirThemePreview
@Composable
private fun AlarmCardPendingPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmCard(
            alarm = sampleAlarmMonthly,
            visualState = AlarmVisualState.Pending,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            onDelete = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirDynamicPreview
@Composable
private fun AlarmCardDynamicPreview() {
    ChronirTheme(dynamicColor = true) {
        AlarmCard(
            alarm = sampleAlarm,
            visualState = AlarmVisualState.Snoozed,
            isEnabled = true,
            onToggle = {},
            onClick = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
