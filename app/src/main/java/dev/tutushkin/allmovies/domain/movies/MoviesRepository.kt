package dev.tutushkin.allmovies.domain.movies

import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList

interface MoviesRepository {

    suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration>

    suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>>

    suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>>

    suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String,
        ensureCached: Boolean = false
    ): Result<MovieDetails>

    suspend fun getActorDetails(
        actorId: Int,
        apiKey: String,
        language: String,
    ): Result<ActorDetails>

    suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit>

    suspend fun getFavorites(): Result<List<MovieList>>

    suspend fun clearAll()

    suspend fun refreshLibrary(
        apiKey: String,
        language: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit>
}