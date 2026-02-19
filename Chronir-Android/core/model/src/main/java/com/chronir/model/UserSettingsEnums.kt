package com.chronir.model

enum class ThemePreference(val displayName: String) {
    LIGHT("Light"),
    DARK("Dark"),
    DYNAMIC("Dynamic")
}

enum class TextSizePreference(val displayName: String, val scaleFactor: Float) {
    COMPACT("Compact", 0.85f),
    STANDARD("Standard", 1.0f),
    LARGE("Large", 1.15f)
}
