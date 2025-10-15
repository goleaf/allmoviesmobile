package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.local.*
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.DraftMovie
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
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
                Result.success(localMovies.map { it.toModel() })
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
                .mapCatching { actors -> movie.toModel(actors) }
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

    override suspend fun saveDraft(movie: DraftMovie): Result<Long> = withContext(ioDispatcher) {
        runCatching {
            val timestamp = System.currentTimeMillis()
            moviesLocalDataSource.upsertDraftMovie(movie.toEntity(timestamp))
        }
    }

    override suspend fun updateDraft(movie: DraftMovie): Result<Unit> = withContext(ioDispatcher) {
        runCatching {
            val timestamp = System.currentTimeMillis()
            moviesLocalDataSource.updateDraftMovie(movie.toEntity(timestamp))
        }
    }

    override suspend fun getDraft(id: Long): Result<DraftMovie?> = withContext(ioDispatcher) {
        runCatching {
            moviesLocalDataSource.getDraftMovie(id)?.toModel()
        }
    }

    override suspend fun getDrafts(): Result<List<DraftMovie>> = withContext(ioDispatcher) {
        runCatching {
            moviesLocalDataSource.getDraftMovies().map { it.toModel() }
        }
    }

    override suspend fun deleteDraft(id: Long): Result<Unit> = withContext(ioDispatcher) {
        runCatching {
            moviesLocalDataSource.deleteDraftMovie(id)
        }
    }

    override suspend fun downloadDraftFromImdb(
        imdbId: String,
        apiKey: String
    ): Result<DraftMovie> = withContext(ioDispatcher) {
        runCatching {
            val findResponse = moviesRemoteDataSource.findByImdb(imdbId, apiKey).getOrThrow()
            val findResult = findResponse.movieResults.firstOrNull()
            val movieId = findResult?.id
                ?: throw NoSuchElementException("Movie not found")
            val details = moviesRemoteDataSource.getMovieDetails(movieId, apiKey).getOrThrow()
            val actors = moviesRemoteDataSource.getActors(movieId, apiKey)
                .getOrDefault(emptyList())

            val akaTitles = mutableListOf<String>()
            if (!findResult?.title.isNullOrBlank()) {
                akaTitles += findResult!!.title
            }
            if (details.title.isNotBlank() && !akaTitles.contains(details.title)) {
                akaTitles += details.title
            }

            val releaseDate = when {
                details.releaseDate.isNotBlank() -> details.releaseDate
                !findResult?.releaseDate.isNullOrBlank() -> findResult!!.releaseDate
                else -> ""
            }

            val notes = if (details.overview.isNotBlank()) {
                details.overview
            } else {
                findResult?.overview.orEmpty()
            }

            DraftMovie(
                id = 0L,
                title = details.title,
                titleOrder = details.title,
                akaTitles = akaTitles,
                durationMinutes = details.runtime.takeIf { it > 0 },
                formats = emptyList(),
                mpaaRating = if (details.adult) DEFAULT_ADULT_MPAA else DEFAULT_GENERAL_MPAA,
                cast = actors.take(MAX_CAST_RESULTS).map { it.name },
                crew = emptyList(),
                trailerUrl = "",
                releaseDate = releaseDate,
                personalNotes = notes,
                imdbId = imdbId,
                coverUri = buildRemotePosterUrl(details.backdropPath ?: findResult?.posterPath),
                createdAt = System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )
        }
    }

    private fun buildRemotePosterUrl(path: String?): String? {
        if (path.isNullOrBlank()) return null
        val baseUrl = NetworkModule.configApi.imagesBaseUrl
        if (baseUrl.isBlank()) {
            return path
        }
        return if (path.startsWith("http")) {
            path
        } else {
            "$baseUrl${DEFAULT_POSTER_SIZE}$path"
        }
    }

    companion object {
        private const val DEFAULT_POSTER_SIZE = "w500"
        private const val DEFAULT_ADULT_MPAA = "NC-17"
        private const val DEFAULT_GENERAL_MPAA = "PG-13"
        private const val MAX_CAST_RESULTS = 10
    }
}