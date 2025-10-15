package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface UserMoviesDao {

    @Query("SELECT * FROM user_movies WHERE movie_id IN (:movieIds)")
    suspend fun get(movieIds: List<Int>): List<UserMovieEntity>

    @Query("SELECT * FROM user_movies WHERE movie_id = :movieId LIMIT 1")
    suspend fun get(movieId: Int): UserMovieEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(userMovieEntity: UserMovieEntity)

    @Delete
    suspend fun delete(userMovieEntity: UserMovieEntity)

    @Query("DELETE FROM user_movies WHERE movie_id = :movieId")
    suspend fun delete(movieId: Int)
}
