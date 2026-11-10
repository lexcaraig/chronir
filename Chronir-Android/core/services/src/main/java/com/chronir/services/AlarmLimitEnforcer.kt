package com.chronir.services

import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.SettingsRepository
import com.chronir.model.Alarm
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Re-applies the Free 3-alarm limit whenever the tier changes: a lapsed Plus subscription turns off the newest
 * alarms beyond the limit (remembering which), and a new upgrade turns exactly those back on.
 */
@Singleton
class AlarmLimitEnforcer
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val settingsRepository: SettingsRepository,
        private val alarmScheduler: AlarmScheduler,
        private val notificationCleanupService: NotificationCleanupService
    ) {
        /** Runs [apply] for every confirmed tier change; an unconfirmed Play state is never treated as Free. */
        suspend fun observe(subscriptionState: Flow<SubscriptionState>) {
            subscriptionState
                .filter { it.isTierResolved }
                .map { it.tier }
                .distinctUntilChanged()
                .collect { apply(it) }
        }

        private suspend fun apply(tier: SubscriptionTier) {
            val alarms = alarmRepository.observeAlarms().first()
            when (tier) {
                SubscriptionTier.FREE -> {
                    val excess = AlarmLimitPolicy.alarmsToDisable(
                        enabled = alarms.filter { it.isEnabled },
                        limit = AlarmLimitPolicy.FREE_TIER_ALARM_LIMIT
                    )
                    if (excess.isEmpty()) return
                    // Remember first: dying between the two steps must not strand disabled alarms.
                    val remembered = settingsRepository.limitDisabledAlarmIds.first()
                    settingsRepository.setLimitDisabledAlarmIds(remembered + excess.map { it.id })
                    excess.forEach { setEnabled(it, false) }
                }
                SubscriptionTier.PLUS -> {
                    val remembered = settingsRepository.limitDisabledAlarmIds.first()
                    if (remembered.isEmpty()) return
                    AlarmLimitPolicy.alarmsToRestore(alarms.filter { !it.isEnabled }, remembered)
                        .forEach { setEnabled(it, true) }
                    settingsRepository.setLimitDisabledAlarmIds(emptySet())
                }
            }
        }

        private suspend fun setEnabled(alarm: Alarm, enabled: Boolean) {
            val updated = alarm.copy(
                isEnabled = enabled,
                isPendingConfirmation = false,
                pendingSince = null,
                updatedAt = Instant.now()
            )
            alarmRepository.updateAlarm(updated)
            if (enabled) {
                alarmScheduler.schedule(updated)
            } else {
                alarmScheduler.cancel(updated.id)
                notificationCleanupService.cancelAlarmNotifications(updated.id)
            }
        }
    }
