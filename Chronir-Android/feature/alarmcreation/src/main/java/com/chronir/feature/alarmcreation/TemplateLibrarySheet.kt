package com.chronir.feature.alarmcreation

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.AlarmTemplate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TemplateLibrarySheet(
    onDismiss: () -> Unit,
    onSelectTemplate: (AlarmTemplate) -> Unit,
    modifier: Modifier = Modifier
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        modifier = modifier
    ) {
        Column(
            modifier = Modifier.padding(horizontal = SpacingTokens.Default)
        ) {
            ChronirText(
                text = "Quick Templates",
                style = ChronirTextStyle.TitleMedium,
                modifier = Modifier.padding(bottom = SpacingTokens.Medium)
            )

            LazyColumn(
                contentPadding = PaddingValues(bottom = SpacingTokens.XXLarge),
                verticalArrangement = Arrangement.spacedBy(SpacingTokens.Small)
            ) {
                items(AlarmTemplate.builtInTemplates) { template ->
                    TemplateCard(
                        template = template,
                        onClick = { onSelectTemplate(template) }
                    )
                }
            }
        }
    }
}

@Composable
private fun TemplateCard(
    template: AlarmTemplate,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val timeFormatter = DateTimeFormatter.ofPattern("h:mm a")

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        shape = RoundedCornerShape(RadiusTokens.Md)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(SpacingTokens.Medium),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                ChronirText(text = template.name, style = ChronirTextStyle.BodyMedium)
                Spacer(Modifier.height(SpacingTokens.XXSmall))
                Row {
                    ChronirBadge(
                        label = template.category.displayName,
                        containerColor = MaterialTheme.colorScheme.secondaryContainer
                    )
                    Spacer(Modifier.width(SpacingTokens.XSmall))
                    ChronirBadge(
                        label = template.cycleType.displayName,
                        containerColor = MaterialTheme.colorScheme.tertiaryContainer
                    )
                }
            }
            ChronirText(
                text = template.timeOfDay.format(timeFormatter),
                style = ChronirTextStyle.BodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
