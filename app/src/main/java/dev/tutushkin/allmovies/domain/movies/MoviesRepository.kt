package dev.tutushkin.allmovies.domain.movies

import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.ImdbSearchResult
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList

interface MoviesRepository {

    suspend fun getConfiguration(apiKey: String): Result<Configuration>

    suspend fun getGenres(apiKey: String): Result<List<Genre>>

    suspend fun getNowPlaying(apiKey: String): Result<List<MovieList>>

    suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetails>

    suspend fun searchImdb(query: String, apiKey: String): Result<List<ImdbSearchResult>>

    suspend fun getImdbMovieDetails(imdbId: String, apiKey: String): Result<MovieDetails>

    suspend fun importImdbMovie(imdbId: String, apiKey: String): Result<MovieDetails>

    suspend fun clearAll()
}