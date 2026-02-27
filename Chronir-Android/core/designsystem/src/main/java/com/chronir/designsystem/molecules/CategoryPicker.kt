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
import androidx.compose.ui.tooling.preview.Preview
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.ColorTokens
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

private fun AlarmCategory.color() = when (this) {
    AlarmCategory.HOME -> ColorTokens.CategoryHome
    AlarmCategory.HEALTH -> ColorTokens.CategoryHealth
    AlarmCategory.FINANCE -> ColorTokens.CategoryFinance
    AlarmCategory.VEHICLE -> ColorTokens.CategoryVehicle
    AlarmCategory.WORK -> ColorTokens.CategoryWork
    AlarmCategory.PERSONAL -> ColorTokens.CategoryPersonal
    AlarmCategory.PETS -> ColorTokens.CategoryPets
    AlarmCategory.SUBSCRIPTIONS -> ColorTokens.CategorySubscriptions
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
        LazyRow(horizontalArrangement = Arrangement.spacedBy(SpacingTokens.Small)) {
            item {
                FilterChip(
                    selected = selected == null,
                    onClick = { onSelect(null) },
                    label = { Text("None") }
                )
            }
            items(AlarmCategory.entries.toList()) { category ->
                val isSelected = selected == category
                FilterChip(
                    selected = isSelected,
                    onClick = { onSelect(if (isSelected) null else category) },
                    label = { Text(category.displayName) },
                    leadingIcon = {
                        Icon(
                            imageVector = category.icon(),
                            contentDescription = category.displayName
                        )
                    },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = category.color().copy(alpha = 0.2f),
                        selectedLabelColor = category.color(),
                        selectedLeadingIconColor = category.color()
                    )
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun CategoryPickerPreview() {
    CategoryPicker(
        selected = AlarmCategory.HOME,
        onSelect = {}
    )
}
