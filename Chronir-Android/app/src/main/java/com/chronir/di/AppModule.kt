package com.chronir.di

import android.content.Context
import com.chronir.data.local.AlarmDao
import com.chronir.data.local.ChronirDatabase
import com.chronir.data.local.CompletionDao
import com.chronir.services.AlarmScheduler
import com.chronir.services.AlarmSchedulerImpl
import dagger.Binds
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
    fun provideDatabase(@ApplicationContext context: Context): ChronirDatabase {
        return ChronirDatabase.create(context)
    }

    @Provides
    @Singleton
    fun provideAlarmDao(database: ChronirDatabase): AlarmDao {
        return database.alarmDao()
    }

    @Provides
    @Singleton
    fun provideCompletionDao(database: ChronirDatabase): CompletionDao {
        return database.completionDao()
    }
}

@Module
@InstallIn(SingletonComponent::class)
abstract class ServiceBindingsModule {

    @Binds
    @Singleton
    abstract fun bindAlarmScheduler(impl: AlarmSchedulerImpl): AlarmScheduler
}
