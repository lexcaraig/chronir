package com.chronir.di

import android.content.Context
import com.chronir.data.local.ChronirDatabase
import com.chronir.data.local.AlarmDao
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
}
