package com.chronir.feature.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.services.SoundOption

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SoundPickerScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    onNavigateToPaywall: () -> Unit = {},
    viewModel: SoundPickerViewModel = hiltViewModel()
) {
    val currentSound by viewModel.currentSound.collectAsStateWithLifecycle()
    val isPlusUser by viewModel.isPlusUser.collectAsStateWithLifecycle()

    DisposableEffect(Unit) {
        onDispose { viewModel.stopPreview() }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Alarm Sound") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        modifier = modifier
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .padding(innerPadding)
                .selectableGroup(),
            contentPadding = PaddingValues(SpacingTokens.Default),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
        ) {
            items(viewModel.allSounds) { sound ->
                SoundRow(
                    sound = sound,
                    isSelected = currentSound == sound.id,
                    isLocked = sound.isPlusTier && !isPlusUser,
                    onSelect = { if (!viewModel.selectSound(sound.id)) onNavigateToPaywall() },
                    onPreview = { viewModel.previewSound(sound.id) }
                )
            }
        }
    }
}

@Composable
private fun SoundRow(
    sound: SoundOption,
    isSelected: Boolean,
    isLocked: Boolean,
    onSelect: () -> Unit,
    onPreview: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // One focus stop per sound: the row is the radio button; the preview button stays separate.
        Row(
            modifier = Modifier
                .weight(1f)
                .selectable(selected = isSelected, role = Role.RadioButton, onClick = onSelect)
                .padding(vertical = SpacingTokens.Small, horizontal = SpacingTokens.XSmall),
            verticalAlignment = Alignment.CenterVertically
        ) {
            RadioButton(selected = isSelected, onClick = null)
            Spacer(Modifier.width(SpacingTokens.Small))
            ChronirText(
                text = sound.displayName,
                style = ChronirTextStyle.BodyMedium,
                modifier = Modifier.weight(1f)
            )
            if (sound.isPlusTier) {
                ChronirBadge(
                    label = if (isLocked) "Plus only" else "Plus",
                    containerColor = ColorTokens.BadgeWarningBackground,
                    contentColor = ColorTokens.BadgeWarningForeground
                )
            }
        }
        IconButton(onClick = onPreview) {
            Icon(
                Icons.Filled.PlayArrow,
                contentDescription = "Preview ${sound.displayName}",
                tint = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}

@ChronirPreview
@Composable
private fun SoundRowPreview() {
    ChronirTheme(dynamicColor = false) {
        Surface {
            Column {
                SoundRow(SoundOption("default", "Default Alarm"), isSelected = true, isLocked = false, onSelect = {}, onPreview = {})
                SoundRow(
                    SoundOption("digital", "Digital Pulse", isPlusTier = true),
                    isSelected = false,
                    isLocked = true,
                    onSelect = {},
                    onPreview = {}
                )
            }
        }
    }
}
