package dev.tutushkin.allmovies.domain.movies

import dev.tutushkin.allmovies.domain.movies.models.Category
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Format
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.LoanRecord
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList

interface MoviesRepository {

    suspend fun getConfiguration(apiKey: String): Result<Configuration>

    suspend fun getGenres(apiKey: String): Result<List<Genre>>

    suspend fun getNowPlaying(apiKey: String): Result<List<MovieList>>

    suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetails>

    suspend fun clearAll()

    suspend fun updateFavorite(movieId: Int, isFavorite: Boolean): Result<Unit>

    suspend fun updateWatched(movieId: Int, isWatched: Boolean): Result<Unit>

    suspend fun updateWatchlist(movieId: Int, isInWatchlist: Boolean): Result<Unit>

    suspend fun updatePersonalNote(movieId: Int, note: String?): Result<Unit>

    suspend fun assignFormat(movieId: Int, formatId: Int?): Result<Unit>

    suspend fun assignCategory(movieId: Int, categoryId: Int?): Result<Unit>

    suspend fun recordLoan(
        movieId: Int,
        borrowerName: String,
        loanDate: Long,
        returnDate: Long?
    ): Result<Unit>

    suspend fun getLoanHistory(movieId: Int): Result<List<LoanRecord>>

    suspend fun getFormats(): Result<List<Format>>

    suspend fun getCategories(): Result<List<Category>>
}