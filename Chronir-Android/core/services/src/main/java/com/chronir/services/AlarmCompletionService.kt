package com.chronir.services

import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.model.CompletionAction
import com.chronir.model.Schedule
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Marks an alarm's upcoming occurrence done from outside the firing screen (widget Mark Done).
 * Mirrors iOS `CompleteAlarmIntent`: the occurrence may not have fired yet, so the schedule advances from
 * max(nextFireDate, now) and the completion is logged as COMPLETED. A pending confirmation is just confirmed.
 */
@Singleton
class AlarmCompletionService
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val completionRepository: CompletionRepository,
        private val alarmScheduler: AlarmScheduler,
        private val dateCalculator: DateCalculator,
        private val pendingConfirmationService: PendingConfirmationService,
        private val notificationCleanupService: NotificationCleanupService
    ) {
        enum class Result { COMPLETED, ALREADY_DONE, NOT_FOUND }

        /**
         * @param expectedFireDateMillis the occurrence the widget showed; a stale or repeated tap is a no-op
         *   instead of completing the following occurrence.
         */
        suspend fun completeUpcoming(alarmId: String, expectedFireDateMillis: Long? = null): Result {
            val alarm = alarmRepository.getAlarmById(alarmId)
            if (alarm == null || !alarm.isEnabled) return Result.NOT_FOUND

            if (alarm.isPendingConfirmation) {
                pendingConfirmationService.confirmDone(alarm)
                return Result.COMPLETED
            }
            if (expectedFireDateMillis != null &&
                kotlin.math.abs(alarm.nextFireDate.toEpochMilli() - expectedFireDateMillis) > 1_000
            ) {
                return Result.ALREADY_DONE
            }

            val now = Instant.now()
            completionRepository.recordCompletion(alarmId = alarm.id, action = CompletionAction.COMPLETED)
            notificationCleanupService.cancelAlarmNotifications(alarm.id)

            if (alarm.schedule is Schedule.OneTime) {
                alarmRepository.updateAlarm(
                    alarm.copy(isEnabled = false, snoozeCount = 0, updatedAt = now)
                )
                alarmScheduler.cancel(alarm.id)
            } else {
                val from = maxOf(alarm.nextFireDate, now)
                val updated = alarm.copy(
                    nextFireDate = dateCalculator.calculateNextFireDate(alarm, from),
                    snoozeCount = 0,
                    updatedAt = now
                )
                alarmRepository.updateAlarm(updated)
                alarmScheduler.schedule(updated) // setAlarmClock for the next occurrence (AE-12)
            }
            return Result.COMPLETED
        }
    }
