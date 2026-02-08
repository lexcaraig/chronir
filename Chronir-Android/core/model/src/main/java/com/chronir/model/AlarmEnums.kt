package com.chronir.model

enum class TimezoneMode {
    FIXED,
    FLOATING
}

enum class PersistenceLevel {
    FULL,
    NOTIFICATION_ONLY,
    SILENT
}

enum class DismissMethod {
    SWIPE,
    HOLD_3S,
    SOLVE_MATH
}

enum class SyncStatus {
    LOCAL_ONLY,
    SYNCED,
    PENDING_SYNC,
    CONFLICT
}
