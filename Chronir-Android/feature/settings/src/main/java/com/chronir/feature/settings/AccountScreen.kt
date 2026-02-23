package com.chronir.feature.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.SpacingTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AccountScreen(
    onBack: () -> Unit,
    onSignInClicked: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AccountViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showDeleteConfirmation by remember { mutableStateOf(false) }

    if (showDeleteConfirmation) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmation = false },
            title = { ChronirText(text = "Delete Account?", style = ChronirTextStyle.TitleMedium) },
            text = {
                ChronirText(
                    text = "This will permanently delete your account and all data. This action cannot be undone.",
                    style = ChronirTextStyle.BodyMedium
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirmation = false
                    viewModel.deleteAccount()
                }) {
                    ChronirText(text = "Delete", style = ChronirTextStyle.BodyMedium, color = ColorTokens.Error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirmation = false }) {
                    ChronirText(text = "Cancel", style = ChronirTextStyle.BodyMedium)
                }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { ChronirText(text = "Account", style = ChronirTextStyle.TitleMedium) },
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
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(SpacingTokens.Default),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(SpacingTokens.Medium)
        ) {
            Spacer(Modifier.height(SpacingTokens.Large))

            // Avatar
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(
                        MaterialTheme.colorScheme.primaryContainer,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (uiState.isSignedIn && !uiState.displayName.isNullOrEmpty()) {
                    ChronirText(
                        text = uiState.displayName!!.first().uppercase(),
                        style = ChronirTextStyle.HeadlineLarge,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                } else {
                    Icon(
                        Icons.Filled.Person,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onPrimaryContainer,
                        modifier = Modifier.size(40.dp)
                    )
                }
            }

            if (uiState.isSignedIn) {
                // Signed in state
                uiState.displayName?.let { name ->
                    ChronirText(
                        text = name,
                        style = ChronirTextStyle.HeadlineSmall
                    )
                }
                uiState.email?.let { email ->
                    ChronirText(
                        text = email,
                        style = ChronirTextStyle.BodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Spacer(Modifier.height(SpacingTokens.XLarge))

                OutlinedButton(
                    onClick = viewModel::signOut,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    ChronirText(text = "Sign Out", style = ChronirTextStyle.BodyMedium)
                }

                Spacer(Modifier.height(SpacingTokens.Small))

                OutlinedButton(
                    onClick = { showDeleteConfirmation = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    ChronirText(
                        text = "Delete Account",
                        style = ChronirTextStyle.BodyMedium,
                        color = ColorTokens.Error
                    )
                }
            } else {
                // Signed out state
                ChronirText(
                    text = "Sign in to back up your alarms and sync across devices.",
                    style = ChronirTextStyle.BodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(Modifier.height(SpacingTokens.Medium))

                ChronirButton(
                    text = "Sign in with Google",
                    onClick = onSignInClicked,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Error
            uiState.errorMessage?.let { error ->
                ChronirText(
                    text = error,
                    style = ChronirTextStyle.BodySmall,
                    color = ColorTokens.Error
                )
            }
        }
    }
}
