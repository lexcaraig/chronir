package com.chronir.designsystem.molecules

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Pets
import androidx.compose.material.icons.filled.Work
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirDynamicPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.ChronirThemePreview
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.model.AlarmCategory

private fun AlarmCategory.icon(): ImageVector = when (this) {
    AlarmCategory.HOME -> Icons.Filled.Home
    AlarmCategory.HEALTH -> Icons.Filled.Favorite
    AlarmCategory.FINANCE -> Icons.Filled.AttachMoney
    AlarmCategory.VEHICLE -> Icons.Filled.DirectionsCar
    AlarmCategory.WORK -> Icons.Filled.Work
    AlarmCategory.PERSONAL -> Icons.Filled.Person
    AlarmCategory.PETS -> Icons.Filled.Pets
    AlarmCategory.SUBSCRIPTIONS -> Icons.Filled.CreditCard
}

@Composable
fun CategoryPicker(
    selected: AlarmCategory?,
    onSelect: (AlarmCategory?) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        ChronirText(
            text = "Category",
            style = ChronirTextStyle.LabelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(bottom = SpacingTokens.XSmall)
        )
        val chipColors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = MaterialTheme.colorScheme.secondaryContainer,
            selectedLabelColor = MaterialTheme.colorScheme.onSecondaryContainer,
            selectedLeadingIconColor = MaterialTheme.colorScheme.onSecondaryContainer
        )
        LazyRow(horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)) {
            item {
                FilterChip(
                    selected = selected == null,
                    onClick = { onSelect(null) },
                    label = { Text("None") },
                    colors = chipColors
                )
            }
            items(AlarmCategory.entries, key = { it.name }) { category ->
                val isSelected = selected == category
                FilterChip(
                    selected = isSelected,
                    onClick = { onSelect(if (isSelected) null else category) },
                    label = { Text(category.displayName) },
                    leadingIcon = {
                        // Decorative: the chip label already names the category.
                        Icon(imageVector = category.icon(), contentDescription = null)
                    },
                    colors = chipColors
                )
            }
        }
    }
}

@ChronirThemePreview
@Composable
private fun CategoryPickerPreview() {
    ChronirTheme(dynamicColor = false) {
        CategoryPicker(
            selected = AlarmCategory.HOME,
            onSelect = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}

@ChronirDynamicPreview
@Composable
private fun CategoryPickerDynamicPreview() {
    ChronirTheme(dynamicColor = true) {
        CategoryPicker(
            selected = AlarmCategory.FINANCE,
            onSelect = {},
            modifier = Modifier.padding(SpacingTokens.Medium)
        )
    }
}
