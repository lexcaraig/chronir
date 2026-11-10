package com.chronir.services

import com.chronir.model.Alarm

/**
 * Which alarms the Free-tier limit turns off, and which ones it may turn back on after an upgrade.
 * Only alarms the limit itself disabled are restored; alarms the user turned off stay off.
 * Mirrors iOS `AlarmLimitPolicy`.
 */
object AlarmLimitPolicy {
    const val FREE_TIER_ALARM_LIMIT = 3

    /** Enabled alarms beyond [limit], newest first to go; the oldest [limit] stay on. */
    fun alarmsToDisable(enabled: List<Alarm>, limit: Int): List<Alarm> {
        if (enabled.size <= limit) return emptyList()
        return enabled.sortedBy { it.createdAt }.drop(limit)
    }

    /** Disabled alarms the limit turned off. Alarms the user turned off are not in [limitDisabled]. */
    fun alarmsToRestore(disabled: List<Alarm>, limitDisabled: Set<String>): List<Alarm> =
        disabled.filter { it.id in limitDisabled }
}
