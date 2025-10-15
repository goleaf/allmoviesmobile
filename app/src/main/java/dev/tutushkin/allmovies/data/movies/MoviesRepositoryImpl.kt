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

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        ensureCached: Boolean
    ): Result<MovieDetails> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearMovieDetails()

            var localMovie = moviesLocalDataSource.getMovieDetails(movieId)

            val shouldRefreshFromServer =
                localMovie == null || (ensureCached && localMovie.isActorsLoaded.not())

            if (shouldRefreshFromServer) {
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
                val summaryEntity = MovieListEntity(
                    id = movieToSave.id,
                    title = movieToSave.title,
                    poster = movieToSave.poster,
                    ratings = movieToSave.ratings,
                    numberOfRatings = movieToSave.numberOfRatings,
                    minimumAge = movieToSave.minimumAge,
                    year = movieToSave.year,
                    genres = movieToSave.genres
                )
                moviesLocalDataSource.setMovie(summaryEntity)

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

    override suspend fun refreshLibrary(
        apiKey: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit> = withContext(ioDispatcher) {
        runCatching {
            val movies = moviesLocalDataSource.getNowPlaying()
            if (movies.isEmpty()) {
                return@runCatching
            }

            val total = movies.size
            movies.forEachIndexed { index, movie ->
                onProgress(index, total, movie.title)

                val existingDetails = moviesLocalDataSource.getMovieDetails(movie.id)

                val movieDetails = getMovieDetailsFromServer(movie.id, apiKey).getOrThrow()
                val actors = getActorsFromServer(movie.id, apiKey).getOrThrow()
                val videos = moviesRemoteDataSource.getVideos(movie.id, apiKey)
                    .getOrDefault(emptyList())
                val trailerUrl = videos.toPreferredTrailerUrl()

                val detailsToSave = movieDetails.copy(
                    poster = movieDetails.poster.ifBlank { existingDetails?.poster ?: movie.poster },
                    actors = actors.map { actor -> actor.id },
                    isActorsLoaded = true,
                    imdbId = movieDetails.imdbId.ifBlank { existingDetails?.imdbId.orEmpty() },
                    trailerUrl = trailerUrl.ifBlank { existingDetails?.trailerUrl.orEmpty() },
                    loanedTo = existingDetails?.loanedTo.orEmpty(),
                    loanedSince = existingDetails?.loanedSince.orEmpty(),
                    loanDue = existingDetails?.loanDue.orEmpty(),
                    loanStatus = existingDetails?.loanStatus.orEmpty(),
                    loanNotes = existingDetails?.loanNotes.orEmpty(),
                    notes = existingDetails?.notes.orEmpty()
                )

                moviesLocalDataSource.setMovieDetails(detailsToSave)
                moviesLocalDataSource.setActors(actors)
                moviesLocalDataSource.setActorsLoaded(movie.id)

                val summaryEntity = MovieListEntity(
                    id = detailsToSave.id,
                    title = detailsToSave.title,
                    poster = detailsToSave.poster.ifBlank { movie.poster },
                    ratings = detailsToSave.ratings,
                    numberOfRatings = detailsToSave.numberOfRatings,
                    minimumAge = detailsToSave.minimumAge,
                    year = detailsToSave.year,
                    genres = detailsToSave.genres
                )
                moviesLocalDataSource.setMovie(summaryEntity)

                onProgress(index + 1, total, movie.title)
            }
        }
    }

}