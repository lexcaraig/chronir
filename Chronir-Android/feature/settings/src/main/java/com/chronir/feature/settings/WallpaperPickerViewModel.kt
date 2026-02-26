package com.chronir.feature.settings

import android.content.Context
import android.net.Uri
import androidx.core.net.toUri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File
import javax.inject.Inject

@HiltViewModel
class WallpaperPickerViewModel
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) : ViewModel() {

        private val wallpaperFile = File(context.filesDir, "alarm_wallpaper.jpg")

        private val _wallpaperUri = MutableStateFlow<Uri?>(
            if (wallpaperFile.exists()) wallpaperFile.toUri() else null
        )
        val wallpaperUri: StateFlow<Uri?> = _wallpaperUri.asStateFlow()

        fun setWallpaper(uri: Uri) {
            viewModelScope.launch(Dispatchers.IO) {
                context.contentResolver.openInputStream(uri)?.use { input ->
                    wallpaperFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                _wallpaperUri.value = wallpaperFile.toUri()
            }
        }

        fun clearWallpaper() {
            viewModelScope.launch(Dispatchers.IO) {
                if (wallpaperFile.exists()) wallpaperFile.delete()
                _wallpaperUri.value = null
            }
        }
    }
