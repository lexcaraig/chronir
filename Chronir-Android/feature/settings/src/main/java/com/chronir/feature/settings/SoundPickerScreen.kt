package com.chronir.feature.settings

import androidx.compose.foundation.clickable
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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.services.SoundOption

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SoundPickerScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: SoundPickerViewModel = hiltViewModel()
) {
    val currentSound by viewModel.currentSound.collectAsStateWithLifecycle()

    DisposableEffect(Unit) {
        onDispose { viewModel.stopPreview() }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { ChronirText(text = "Alarm Sound", style = ChronirTextStyle.TitleMedium) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        },
        modifier = modifier
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier.padding(innerPadding),
            contentPadding = PaddingValues(SpacingTokens.Default),
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.XSmall)
        ) {
            items(viewModel.allSounds) { sound ->
                SoundRow(
                    sound = sound,
                    isSelected = currentSound == sound.id,
                    onSelect = { viewModel.selectSound(sound.id) },
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
    onSelect: () -> Unit,
    onPreview: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onSelect)
            .padding(vertical = SpacingTokens.Small, horizontal = SpacingTokens.XSmall),
        verticalAlignment = Alignment.CenterVertically
    ) {
        RadioButton(selected = isSelected, onClick = onSelect)
        Spacer(Modifier.width(SpacingTokens.Small))
        Column(modifier = Modifier.weight(1f)) {
            ChronirText(text = sound.displayName, style = ChronirTextStyle.BodyMedium)
        }
        if (sound.isPlusTier) {
            ChronirBadge(label = "Plus", containerColor = ColorTokens.Warning)
            Spacer(Modifier.width(SpacingTokens.Small))
        }
        IconButton(onClick = onPreview) {
            Icon(
                Icons.Filled.PlayArrow,
                contentDescription = "Preview",
                tint = MaterialTheme.colorScheme.primary
            )
        }
    }
}
