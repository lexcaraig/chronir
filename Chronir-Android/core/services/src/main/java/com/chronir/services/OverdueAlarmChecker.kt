package com.chronir.services

import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class OverdueAlarmChecker
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository
    ) {
        suspend fun findFirstOverdueAlarm(): Alarm? {
            val now = Instant.now()
            return alarmRepository.getEnabledAlarms()
                .filter { it.nextFireDate.isBefore(now) && !it.isPendingConfirmation }
                .minByOrNull { it.nextFireDate }
        }
    }
