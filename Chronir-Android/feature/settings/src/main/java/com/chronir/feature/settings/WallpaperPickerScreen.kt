package com.chronir.feature.settings

import android.graphics.BitmapFactory
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.chronir.designsystem.atoms.ChronirButton
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WallpaperPickerScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: WallpaperPickerViewModel = hiltViewModel()
) {
    val wallpaperUri by viewModel.wallpaperUri.collectAsStateWithLifecycle()

    val photoPicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri ->
        uri?.let { viewModel.setWallpaper(it) }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Wallpaper") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
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
            ChronirText(
                text = "Customize the alarm firing background",
                style = ChronirTextStyle.BodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(9f / 16f)
                    .clip(RoundedCornerShape(RadiusTokens.Lg))
            ) {
                val uri = wallpaperUri
                if (uri != null) {
                    val bitmap by produceState<ImageBitmap?>(initialValue = null, uri) {
                        value = withContext(Dispatchers.IO) { decodeSampled(uri.path, PREVIEW_MAX_PX) }
                    }
                    bitmap?.let { image ->
                        Image(
                            bitmap = image,
                            contentDescription = "Wallpaper preview",
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    }
                } else {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        ChronirText(
                            text = "No wallpaper set",
                            style = ChronirTextStyle.BodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            ChronirButton(
                text = "Choose Photo",
                onClick = {
                    photoPicker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                },
                modifier = Modifier.fillMaxWidth()
            )

            if (wallpaperUri != null) {
                OutlinedButton(
                    onClick = { viewModel.clearWallpaper() },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    ChronirText(text = "Remove Wallpaper", style = ChronirTextStyle.BodyMedium)
                }
            }

            Spacer(Modifier.height(SpacingTokens.Large))
        }
    }
}

/** Longest edge the 9:16 preview needs; decoding a full 12 MP photo for it wastes ~48 MB. */
private const val PREVIEW_MAX_PX = 1080

/** Decodes [path] downsampled by a power of two so its longest edge is about [maxPx]. Call off the main thread. */
private fun decodeSampled(path: String?, maxPx: Int): ImageBitmap? {
    if (path == null) return null
    val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeFile(path, bounds)
    var sample = 1
    while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= maxPx) sample *= 2
    return BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample })?.asImageBitmap()
}
