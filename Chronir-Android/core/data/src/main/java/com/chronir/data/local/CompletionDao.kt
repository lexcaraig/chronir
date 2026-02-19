package com.chronir.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface CompletionDao {

    @Query("SELECT * FROM completions WHERE alarmId = :alarmId ORDER BY timestamp DESC")
    fun observeByAlarmId(alarmId: String): Flow<List<CompletionEntity>>

    @Query("SELECT * FROM completions ORDER BY timestamp DESC LIMIT :limit")
    fun observeRecent(limit: Int = 50): Flow<List<CompletionEntity>>

    @Query("SELECT COUNT(*) FROM completions WHERE alarmId = :alarmId AND action = 'COMPLETED'")
    suspend fun getCompletionCount(alarmId: String): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(completion: CompletionEntity)

    @Query("DELETE FROM completions WHERE alarmId = :alarmId")
    suspend fun deleteByAlarmId(alarmId: String)
}
