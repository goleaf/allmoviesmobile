package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.*
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext

class MoviesRepositoryImpl(
    private val moviesRemoteDataSource: MoviesRemoteDataSource,
    private val moviesLocalDataSource: MoviesLocalDataSource,
    private val ioDispatcher: CoroutineDispatcher
) : MoviesRepository {

    override suspend fun getConfiguration(apiKey: String): Result<Configuration> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearConfiguration()
            var localConfiguration = moviesLocalDataSource.getConfiguration()

            if (localConfiguration == null) {
                getConfigurationFromServer(apiKey)
                    .onSuccess { moviesLocalDataSource.setConfiguration(it) }
                    .onFailure {
                        return@withContext Result.failure(it)
                    }

                localConfiguration = moviesLocalDataSource.getConfiguration()
            }

            if (localConfiguration != null) {
                Result.success(localConfiguration.toModel())
            } else {
                Result.failure(Exception("Configuration cashing error!"))
            }
        }

    private suspend fun getConfigurationFromServer(apiKey: String): Result<ConfigurationEntity> =
        withContext(ioDispatcher) {
            moviesRemoteDataSource.getConfiguration(apiKey)
                .mapCatching { it.toEntity() }
        }

    override suspend fun getGenres(apiKey: String): Result<List<Genre>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearGenres()
            var localGenres = moviesLocalDataSource.getGenres()

            if (localGenres.isEmpty()) {
                getGenresFromServer(apiKey)
                    .onSuccess { moviesLocalDataSource.setGenres(it) }
                    .onFailure {
                        return@withContext Result.failure(it)
                    }

                localGenres = moviesLocalDataSource.getGenres()
            }

            if (localGenres.isNotEmpty()) {
                Result.success(localGenres.map { it.toModel() })
            } else {
                Result.success(emptyList())
            }
        }

    private suspend fun getGenresFromServer(apiKey: String): Result<List<GenreEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getGenres(apiKey)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun getNowPlaying(apiKey: String): Result<List<MovieList>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearNowPlaying()
            var localMovies = moviesLocalDataSource.getNowPlaying()

            if (localMovies.isEmpty()) {
                getNowPlayingFromServer(apiKey)
                    .onSuccess { moviesLocalDataSource.setNowPlaying(it) }
                    .onFailure {
                        return@withContext Result.failure(it)
                    }

                localMovies = moviesLocalDataSource.getNowPlaying()
            }

            if (localMovies.isNotEmpty()) {
                val movieIds = localMovies.map { it.id }
                val userMovies = moviesLocalDataSource.getUserMovies(movieIds).associateBy { it.movieId }
                val personalNotes = moviesLocalDataSource.getPersonalNotes(movieIds).associateBy { it.movieId }
                val formatsById = moviesLocalDataSource.getFormats().associateBy { it.id }
                val categoriesById = moviesLocalDataSource.getCategories().associateBy { it.id }

                Result.success(
                    localMovies.map { entity ->
                        val userMovie = userMovies[entity.id]
                        val format = userMovie?.formatId?.let(formatsById::get)
                        val category = userMovie?.categoryId?.let(categoriesById::get)

                        entity.toModel(
                            userMovie = userMovie,
                            personalNote = personalNotes[entity.id],
                            format = format,
                            category = category
                        )
                    }
                )
            } else {
                Result.success(emptyList())
            }
        }

    private suspend fun getNowPlayingFromServer(apiKey: String): Result<List<MovieListEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getNowPlaying(apiKey)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetails> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearMovieDetails()

            var localMovie = moviesLocalDataSource.getMovieDetails(movieId)

            if (localMovie == null) {
                val movieDetailsResult = getMovieDetailsFromServer(movieId, apiKey)
                movieDetailsResult.onFailure {
                    return@withContext Result.failure(it)
                }

                val actorsResult = getActorsFromServer(movieId, apiKey)
                actorsResult.onFailure {
                    return@withContext Result.failure(it)
                }

                val movieDetails = movieDetailsResult.getOrThrow()
                val actors = actorsResult.getOrThrow()
                val movieToSave = movieDetails.copy(
                    actors = actors.map { actor -> actor.id },
                    isActorsLoaded = true
                )

                moviesLocalDataSource.setMovieDetails(movieToSave)
                moviesLocalDataSource.setActors(actors)

                localMovie = moviesLocalDataSource.getMovieDetails(movieId) ?: movieToSave
            }

            val movie = localMovie
            if (movie == null) {
                return@withContext Result.failure(Exception("Movie details cashing error!"))
            }

            return@withContext getActorsData(movie, apiKey)
                .mapCatching { actors ->
                    val userMovie = moviesLocalDataSource.getUserMovie(movie.id)
                    val note = moviesLocalDataSource.getPersonalNote(movie.id)
                    val format = userMovie?.formatId?.let { moviesLocalDataSource.getFormatById(it) }
                    val category = userMovie?.categoryId?.let { moviesLocalDataSource.getCategoryById(it) }
                    val loanRecords = moviesLocalDataSource.getLoanHistory(movie.id)

                    movie.toModel(
                        actors = actors,
                        userMovie = userMovie,
                        personalNote = note,
                        format = format,
                        category = category,
                        loanRecords = loanRecords
                    )
                }
        }

    private suspend fun getMovieDetailsFromServer(
        movieId: Int,
        apiKey: String
    ): Result<MovieDetailsEntity> =
        withContext(ioDispatcher) {
            moviesRemoteDataSource.getMovieDetails(movieId, apiKey)
                .mapCatching { it.toEntity() }
        }

    private suspend fun getActorsData(
        movie: MovieDetailsEntity,
        apiKey: String
    ): Result<List<Actor>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearActors()

            if (!movie.isActorsLoaded) {
                getActorsFromServer(movie.id, apiKey)
                    .onSuccess {
                        moviesLocalDataSource.setActors(it)
                        moviesLocalDataSource.setActorsLoaded(movie.id)
                    }
                    .onFailure {
                        return@withContext Result.failure(it)
                    }
            }

            val localActors = moviesLocalDataSource.getActors(movie.actors)

            if (localActors.isNotEmpty()) {
                Result.success(localActors.map { it.toModel() })
            } else {
                Result.success(emptyList())
            }
        }

    private suspend fun getActorsFromServer(
        movieId: Int,
        apiKey: String
    ): Result<List<ActorEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getActors(movieId, apiKey)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun clearAll() {
        withContext(ioDispatcher) {
            moviesLocalDataSource.clearConfiguration()
            moviesLocalDataSource.clearGenres()
            moviesLocalDataSource.clearNowPlaying()
            moviesLocalDataSource.clearMovieDetails()
            moviesLocalDataSource.clearActors()
        }
    }

    override suspend fun updateFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> =
        updateUserMovie(movieId) { current ->
            current.copy(isFavorite = isFavorite)
        }

    override suspend fun updateWatched(movieId: Int, isWatched: Boolean): Result<Unit> =
        updateUserMovie(movieId) { current ->
            current.copy(isWatched = isWatched)
        }

    override suspend fun updateWatchlist(movieId: Int, isInWatchlist: Boolean): Result<Unit> =
        updateUserMovie(movieId) { current ->
            current.copy(isInWatchlist = isInWatchlist)
        }

    override suspend fun updatePersonalNote(movieId: Int, note: String?): Result<Unit> =
        withContext(ioDispatcher) {
            runCatching {
                if (note.isNullOrBlank()) {
                    moviesLocalDataSource.deletePersonalNote(movieId)
                } else {
                    moviesLocalDataSource.upsertPersonalNote(
                        PersonalNoteEntity(
                            movieId = movieId,
                            note = note,
                            updatedAt = System.currentTimeMillis()
                        )
                    )
                }
            }
        }

    override suspend fun assignFormat(movieId: Int, formatId: Int?): Result<Unit> =
        withContext(ioDispatcher) {
            runCatching {
                if (formatId != null && moviesLocalDataSource.getFormatById(formatId) == null) {
                    throw IllegalArgumentException("Format with id $formatId does not exist")
                }

                val updated = ensureUserMovie(movieId).copy(formatId = formatId)
                moviesLocalDataSource.upsertUserMovie(updated)
            }
        }

    override suspend fun assignCategory(movieId: Int, categoryId: Int?): Result<Unit> =
        withContext(ioDispatcher) {
            runCatching {
                if (categoryId != null && moviesLocalDataSource.getCategoryById(categoryId) == null) {
                    throw IllegalArgumentException("Category with id $categoryId does not exist")
                }

                val updated = ensureUserMovie(movieId).copy(categoryId = categoryId)
                moviesLocalDataSource.upsertUserMovie(updated)
            }
        }

    override suspend fun recordLoan(
        movieId: Int,
        borrowerName: String,
        loanDate: Long,
        returnDate: Long?
    ): Result<Unit> = withContext(ioDispatcher) {
        runCatching {
            if (borrowerName.isBlank()) {
                throw IllegalArgumentException("Borrower name must not be blank")
            }

            moviesLocalDataSource.insertLoanRecord(
                LoanRecordEntity(
                    movieId = movieId,
                    borrowerName = borrowerName,
                    loanDate = loanDate,
                    returnDate = returnDate
                )
            )
        }
    }

    override suspend fun getLoanHistory(movieId: Int): Result<List<LoanRecord>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesLocalDataSource.getLoanHistory(movieId)
                    .map { it.toModel() }
            }
        }

    override suspend fun getFormats(): Result<List<Format>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesLocalDataSource.getFormats().map { it.toModel() }
            }
        }

    override suspend fun getCategories(): Result<List<Category>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesLocalDataSource.getCategories().map { it.toModel() }
            }
        }

    private suspend fun updateUserMovie(
        movieId: Int,
        reducer: (UserMovieEntity) -> UserMovieEntity
    ): Result<Unit> = withContext(ioDispatcher) {
        runCatching {
            val current = ensureUserMovie(movieId)
            val updated = reducer(current)
            moviesLocalDataSource.upsertUserMovie(updated)
        }
    }

    private suspend fun ensureUserMovie(movieId: Int): UserMovieEntity {
        return moviesLocalDataSource.getUserMovie(movieId) ?: UserMovieEntity(movieId = movieId)
    }
}