package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update

@Dao
interface DraftMovieDao {

    @Query("SELECT * FROM draft_movies ORDER BY updated_at DESC")
    suspend fun getAll(): List<DraftMovieEntity>

    @Query("SELECT * FROM draft_movies WHERE id = :id LIMIT 1")
    suspend fun getById(id: Long): DraftMovieEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(movie: DraftMovieEntity): Long

    @Update
    suspend fun update(movie: DraftMovieEntity)

    @Query("DELETE FROM draft_movies WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("DELETE FROM draft_movies")
    suspend fun clear()
}
