package com.cyclealarm.di

import android.content.Context
import com.cyclealarm.data.local.CycleAlarmDatabase
import com.cyclealarm.data.local.AlarmDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): CycleAlarmDatabase {
        return CycleAlarmDatabase.create(context)
    }

    @Provides
    @Singleton
    fun provideAlarmDao(database: CycleAlarmDatabase): AlarmDao {
        return database.alarmDao()
    }
}
