package com.chronir.designsystem.theme

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.tooling.preview.Wallpapers

/**
 * Multi-theme preview: renders light, dark, and large font variants.
 * Apply to any @Composable preview function to get all three at once.
 */
@Preview(name = "Light", showBackground = true)
@Preview(name = "Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Preview(name = "Large Font", showBackground = true, fontScale = 2f)
annotation class ChronirPreview

/**
 * Theme-only preview: light and dark mode without large font.
 */
@Preview(name = "Light", showBackground = true)
@Preview(name = "Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
annotation class ChronirThemePreview

/**
 * Dynamic-color preview: Material You from a sample wallpaper, light and dark. Wrap the content in
 * `ChronirTheme(dynamicColor = true)` — this is the branch fresh installs ship with.
 */
@Preview(name = "Dynamic — Light", showBackground = true, wallpaper = Wallpapers.BLUE_DOMINATED_EXAMPLE)
@Preview(
    name = "Dynamic — Dark",
    showBackground = true,
    uiMode = UI_MODE_NIGHT_YES,
    wallpaper = Wallpapers.BLUE_DOMINATED_EXAMPLE
)
annotation class ChronirDynamicPreview
