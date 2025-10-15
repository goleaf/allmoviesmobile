package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface MovieDetailsDao {

    @Query("SELECT * FROM movie_details WHERE id = :id")
    fun getMovieDetails(id: Int): MovieDetailsEntity?

    @Query("SELECT * FROM movie_details WHERE isFavorite = 1")
    fun getFavorites(): List<MovieDetailsEntity>

    @Query("UPDATE movie_details SET isFavorite = :isFavorite WHERE id = :movieId")
    fun updateFavorite(movieId: Int, isFavorite: Boolean)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(movie: MovieDetailsEntity): Long

    @Query("SELECT * FROM movie_details")
    fun getAll(): List<MovieDetailsEntity>

    @Query("UPDATE movie_details SET isActorsLoaded = 1 WHERE id = :id")
    fun setActorsLoaded(id: Int)

    @Query("DELETE FROM movie_details WHERE id = :id")
    fun delete(id: Int)

    @Query("DELETE FROM movie_details")
    fun clear()
}