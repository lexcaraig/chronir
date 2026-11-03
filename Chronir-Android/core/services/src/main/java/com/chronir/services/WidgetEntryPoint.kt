package com.chronir.services

import com.chronir.data.repository.AlarmRepository
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

/** Hilt access for Glance widgets and their action callbacks, which Hilt can't inject directly. */
@EntryPoint
@InstallIn(SingletonComponent::class)
interface WidgetEntryPoint {
    fun alarmRepository(): AlarmRepository

    fun alarmCompletionService(): AlarmCompletionService
}
