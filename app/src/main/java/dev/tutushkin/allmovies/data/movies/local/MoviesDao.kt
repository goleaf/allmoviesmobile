package dev.tutushkin.allmovies.data.movies.local

import androidx.room.*

@Dao
interface MoviesDao {

    @Transaction
    @Query("SELECT * FROM movies")
    fun getNowPlaying(): List<MovieListEntity>

    @Query("SELECT * FROM movies WHERE id = :movieId LIMIT 1")
    fun getMovie(movieId: Int): MovieListEntity?

    @Query("SELECT * FROM movies WHERE isFavorite = 1")
    fun getFavorites(): List<MovieListEntity>

    @Query("UPDATE movies SET isFavorite = :isFavorite WHERE id = :movieId")
    fun updateFavorite(movieId: Int, isFavorite: Boolean)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(movie: MovieListEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(movies: List<MovieListEntity>)

    @Query("DELETE FROM movies WHERE id = :id")
    fun delete(id: Int)

    @Query("DELETE FROM movies")
    fun clear()
}