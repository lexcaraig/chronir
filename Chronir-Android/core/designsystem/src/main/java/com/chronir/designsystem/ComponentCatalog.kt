package com.chronir.designsystem

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirButtonStyle
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.atoms.ChronirToggle
import com.chronir.designsystem.molecules.AlarmTimeDisplay
import com.chronir.designsystem.molecules.AlarmToggleRow
import com.chronir.designsystem.molecules.SnoozeOptionBar
import com.chronir.designsystem.organisms.AlarmCard
import com.chronir.designsystem.organisms.AlarmVisualState
import com.chronir.designsystem.templates.SingleColumnTemplate
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime

@Composable
fun ComponentCatalog(
    modifier: Modifier = Modifier
) {
    var expandedSection by remember { mutableStateOf<String?>(null) }

    SingleColumnTemplate(
        title = "Design System",
        modifier = modifier
    ) {
        CatalogSection(title = "Atoms", isExpanded = expandedSection == "atoms", onToggle = {
            expandedSection =
                if (expandedSection == "atoms") null else "atoms"
        }) {
            // ChronirText samples
            ChronirText(text = "Display Alarm", style = ChronirTextStyle.DisplayAlarm)
            ChronirText(text = "Headline Time", style = ChronirTextStyle.HeadlineTime)
            ChronirText(text = "Headline Title", style = ChronirTextStyle.HeadlineTitle)
            ChronirText(text = "Body Primary", style = ChronirTextStyle.BodyPrimary)
            ChronirText(text = "Body Secondary", style = ChronirTextStyle.BodySecondary, color = MaterialTheme.colorScheme.onSurfaceVariant)

            Spacer(Modifier.height(SpacingTokens.Medium))

            // Buttons
            ChronirButton(text = "Primary", onClick = {})
            ChronirButton(text = "Secondary", onClick = {}, style = ChronirButtonStyle.Secondary)
            ChronirButton(text = "Destructive", onClick = {}, style = ChronirButtonStyle.Destructive)
            ChronirButton(text = "Ghost", onClick = {}, style = ChronirButtonStyle.Ghost)

            Spacer(Modifier.height(SpacingTokens.Medium))

            // Badges
            Row(horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)) {
                ChronirBadge(
                    label = "Weekly",
                    containerColor = ColorTokens.BadgeWeeklyBackground,
                    contentColor = ColorTokens.BadgeWeeklyForeground
                )
                ChronirBadge(
                    label = "Monthly",
                    containerColor = ColorTokens.BadgeMonthlyBackground,
                    contentColor = ColorTokens.BadgeMonthlyForeground
                )
                ChronirBadge(
                    label = "Annual",
                    containerColor = ColorTokens.BadgeAnnualBackground,
                    contentColor = ColorTokens.BadgeAnnualForeground
                )
                ChronirBadge(
                    label = "Custom",
                    containerColor = ColorTokens.BadgeCustomBackground,
                    contentColor = ColorTokens.BadgeCustomForeground
                )
            }

            Spacer(Modifier.height(SpacingTokens.Medium))

            // Toggle
            var toggleState by remember { mutableStateOf(true) }
            ChronirToggle(checked = toggleState, onCheckedChange = { toggleState = it })
        }

        CatalogSection(title = "Molecules", isExpanded = expandedSection == "molecules", onToggle = {
            expandedSection =
                if (expandedSection == "molecules") null else "molecules"
        }) {
            AlarmTimeDisplay(timeText = "3:45 PM", countdownText = "Alarm in 6h 32m")
            Spacer(Modifier.height(SpacingTokens.Medium))
            AlarmToggleRow(title = "Workout", subtitle = "Every Monday", isEnabled = true, onToggle = {
            }, badgeLabel = "Weekly", badgeColor = ColorTokens.BadgeWeeklyBackground)
            Spacer(Modifier.height(SpacingTokens.Medium))
            SnoozeOptionBar(onSnooze = {})
        }

        CatalogSection(title = "Organisms", isExpanded = expandedSection == "organisms", onToggle = {
            expandedSection =
                if (expandedSection == "organisms") null else "organisms"
        }) {
            AlarmCard(
                alarm = Alarm(
                    title = "Active Card",
                    cycleType = CycleType.WEEKLY,
                    timeOfDay = LocalTime.of(7, 0),
                    schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
                    nextFireDate = Instant.now().plusSeconds(3600),
                    persistenceLevel = PersistenceLevel.FULL
                ),
                visualState = AlarmVisualState.Active,
                isEnabled = true,
                onToggle = {},
                onClick = {}
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            AlarmCard(
                alarm = Alarm(
                    title = "Snoozed Card",
                    cycleType = CycleType.MONTHLY_DATE,
                    timeOfDay = LocalTime.of(9, 0),
                    schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
                    nextFireDate = Instant.now()
                ),
                visualState = AlarmVisualState.Snoozed,
                isEnabled = true,
                onToggle = {},
                onClick = {}
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            AlarmCard(
                alarm = Alarm(
                    title = "Overdue Card",
                    cycleType = CycleType.ANNUAL,
                    timeOfDay = LocalTime.of(10, 0),
                    schedule = Schedule.Annual(month = 3, dayOfMonth = 15, interval = 1),
                    nextFireDate = Instant.now().minusSeconds(3600)
                ),
                visualState = AlarmVisualState.Overdue,
                isEnabled = true,
                onToggle = {},
                onClick = {}
            )
        }

        CatalogSection(title = "Templates", isExpanded = expandedSection == "templates", onToggle = {
            expandedSection =
                if (expandedSection == "templates") null else "templates"
        }) {
            ChronirText(
                text = "SingleColumnTemplate — wraps scrollable content with top bar",
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            ChronirText(
                text = "ModalSheetTemplate — bottom sheet with content slot",
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.height(SpacingTokens.Small))
            ChronirText(
                text = "FullScreenAlarmTemplate — full-screen overlay for firing",
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun CatalogSection(
    title: String,
    isExpanded: Boolean,
    onToggle: () -> Unit,
    content: @Composable () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(role = Role.Button, onClickLabel = if (isExpanded) "Collapse" else "Expand", onClick = onToggle)
                .padding(SpacingTokens.Medium),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            ChronirText(text = title, style = ChronirTextStyle.TitleSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        if (isExpanded) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = SpacingTokens.Medium)
                    .padding(bottom = SpacingTokens.Medium)
            ) {
                content()
            }
        }
        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
    }
}

@ChronirThemePreview
@Composable
private fun ComponentCatalogPreview() {
    ChronirTheme(dynamicColor = false) {
        ComponentCatalog()
    }
}
