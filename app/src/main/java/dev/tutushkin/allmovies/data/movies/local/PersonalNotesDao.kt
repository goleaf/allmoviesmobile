package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface PersonalNotesDao {

    @Query("SELECT * FROM personal_notes WHERE movie_id IN (:movieIds)")
    suspend fun get(movieIds: List<Int>): List<PersonalNoteEntity>

    @Query("SELECT * FROM personal_notes WHERE movie_id = :movieId LIMIT 1")
    suspend fun get(movieId: Int): PersonalNoteEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(personalNoteEntity: PersonalNoteEntity)

    @Query("DELETE FROM personal_notes WHERE movie_id = :movieId")
    suspend fun delete(movieId: Int)
}
