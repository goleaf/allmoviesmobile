package dev.tutushkin.allmovies.data.movies.local

import androidx.room.*
import androidx.sqlite.db.SupportSQLiteQuery

@Dao
interface MoviesDao {

    @Transaction
    @Query("SELECT * FROM movies")
    fun getNowPlaying(): List<MovieListEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(movie: MovieListEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(movies: List<MovieListEntity>)

    @Query("DELETE FROM movies WHERE id = :id")
    fun delete(id: Int)

    @Query("DELETE FROM movies")
    fun clear()

    @RawQuery(observedEntities = [MovieListEntity::class, MovieDetailsEntity::class])
    suspend fun search(query: SupportSQLiteQuery): List<MovieListEntity>

    @RawQuery(observedEntities = [MovieListEntity::class, MovieDetailsEntity::class])
    suspend fun count(query: SupportSQLiteQuery): Long
}