package dev.tutushkin.allmovies.domain.movies

import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.DraftMovie
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList

interface MoviesRepository {

    suspend fun getConfiguration(apiKey: String): Result<Configuration>

    suspend fun getGenres(apiKey: String): Result<List<Genre>>

    suspend fun getNowPlaying(apiKey: String): Result<List<MovieList>>

    suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetails>

    suspend fun clearAll()

    suspend fun saveDraft(movie: DraftMovie): Result<Long>

    suspend fun updateDraft(movie: DraftMovie): Result<Unit>

    suspend fun getDraft(id: Long): Result<DraftMovie?>

    suspend fun getDrafts(): Result<List<DraftMovie>>

    suspend fun deleteDraft(id: Long): Result<Unit>

    suspend fun downloadDraftFromImdb(imdbId: String, apiKey: String): Result<DraftMovie>
}