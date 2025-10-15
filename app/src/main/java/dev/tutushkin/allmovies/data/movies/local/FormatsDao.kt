package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update

@Dao
interface FormatsDao {

    @Query("SELECT * FROM formats")
    suspend fun getAll(): List<FormatEntity>

    @Query("SELECT * FROM formats WHERE id = :id")
    suspend fun getById(id: Int): FormatEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(formatEntity: FormatEntity): Long

    @Update
    suspend fun update(formatEntity: FormatEntity)

    @Delete
    suspend fun delete(formatEntity: FormatEntity)
}
