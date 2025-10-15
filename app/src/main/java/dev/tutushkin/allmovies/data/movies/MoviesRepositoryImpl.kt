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

    override suspend fun getConfiguration(language: String): Result<Configuration> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearConfiguration()
            var localConfiguration = moviesLocalDataSource.getConfiguration()

            if (localConfiguration == null) {
                getConfigurationFromServer(language)
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

    private suspend fun getConfigurationFromServer(
        language: String
    ): Result<ConfigurationEntity> =
        withContext(ioDispatcher) {
            moviesRemoteDataSource.getConfiguration(language)
                .mapCatching { it.toEntity() }
        }

    override suspend fun getGenres(language: String): Result<List<Genre>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearGenres()
            var localGenres = moviesLocalDataSource.getGenres()

            if (localGenres.isEmpty()) {
                getGenresFromServer(language)
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

    private suspend fun getGenresFromServer(
        language: String
    ): Result<List<GenreEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getGenres(language)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun getNowPlaying(language: String): Result<List<MovieList>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearNowPlaying()
            var localMovies = moviesLocalDataSource.getNowPlaying()

            if (localMovies.isEmpty()) {
                val remoteMovies = getNowPlayingFromServer(language)
                val moviesToSave = remoteMovies.getOrElse { error ->
                    return@withContext Result.failure(error)
                }

                val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()
                val merged = moviesToSave.map { entity ->
                    val isFavorite = favoriteIds.contains(entity.id)
                    entity.copy(isFavorite = isFavorite)
                }

                moviesLocalDataSource.setNowPlaying(merged)
                localMovies = moviesLocalDataSource.getNowPlaying()
            } else {
                val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()
                if (favoriteIds.isNotEmpty()) {
                    val updated = localMovies.map { entity ->
                        val isFavorite = favoriteIds.contains(entity.id)
                        if (entity.isFavorite == isFavorite) entity else entity.copy(isFavorite = isFavorite)
                    }
                    if (updated != localMovies) {
                        moviesLocalDataSource.setNowPlaying(updated)
                        localMovies = moviesLocalDataSource.getNowPlaying()
                    }
                }
            }

            if (localMovies.isNotEmpty()) {
                Result.success(localMovies.map { it.toModel() })
            } else {
                Result.success(emptyList())
            }
        }

    override suspend fun searchMovies(
        language: String,
        query: String,
        includeAdult: Boolean,
    ): Result<List<MovieList>> = withContext(ioDispatcher) {
        val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds().toSet()

        // Search results are fetched on demand and remain remote-only to avoid polluting cached lists.
        moviesRemoteDataSource.searchMovies(language, query, includeAdult)
            .mapCatching { dtos ->
                dtos.map { dto ->
                    val entity = dto.toEntity()
                    val merged = if (favoriteIds.contains(entity.id)) {
                        entity.copy(isFavorite = true)
                    } else {
                        entity
                    }
                    merged.toModel()
                }
            }
    }

    private suspend fun getNowPlayingFromServer(
        language: String
    ): Result<List<MovieListEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getNowPlaying(language)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun getMovieDetails(
        movieId: Int,
        language: String,
        ensureCached: Boolean
    ): Result<MovieDetails> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearMovieDetails()

            var localMovie = moviesLocalDataSource.getMovieDetails(movieId)

            val shouldRefreshFromServer =
                localMovie == null || (ensureCached && localMovie.isActorsLoaded.not())

            if (shouldRefreshFromServer) {
                val movieDetailsResult = getMovieDetailsFromServer(movieId, language)
                movieDetailsResult.onFailure {
                    return@withContext Result.failure(it)
                }

                val actorsResult = getActorsFromServer(movieId, language)
                actorsResult.onFailure {
                    return@withContext Result.failure(it)
                }

                val movieDetails = movieDetailsResult.getOrThrow()
                val actors = actorsResult.getOrThrow()
                val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()
                val isFavorite = favoriteIds.contains(movieDetails.id)
                val movieToSave = movieDetails.copy(
                    actors = actors.map { actor -> actor.id },
                    isActorsLoaded = true,
                    isFavorite = isFavorite
                )

                moviesLocalDataSource.setMovieDetails(movieToSave)
                moviesLocalDataSource.setActors(actors)
                val existingMovie = moviesLocalDataSource.getMovie(movieId)
                val summaryEntity = MovieListEntity(
                    id = movieToSave.id,
                    title = movieToSave.title,
                    poster = movieToSave.poster,
                    ratings = movieToSave.ratings,
                    numberOfRatings = movieToSave.numberOfRatings,
                    minimumAge = movieToSave.minimumAge,
                    year = movieToSave.year,
                    genres = movieToSave.genres,
                    isFavorite = isFavorite || (existingMovie?.isFavorite ?: false)
                )
                moviesLocalDataSource.setMovie(summaryEntity)

                localMovie = moviesLocalDataSource.getMovieDetails(movieId) ?: movieToSave
            } else if (localMovie != null) {
                val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()
                val isFavorite = favoriteIds.contains(localMovie.id)
                if (localMovie.isFavorite != isFavorite) {
                    val updated = localMovie.copy(isFavorite = isFavorite)
                    moviesLocalDataSource.setMovieDetails(updated)
                    localMovie = updated
                }
            }

            val movie = localMovie
            if (movie == null) {
                return@withContext Result.failure(Exception("Movie details cashing error!"))
            }

            return@withContext getActorsData(movie, language)
                .mapCatching { actors -> movie.toModel(actors) }
        }

    override suspend fun getActorDetails(
        actorId: Int,
        language: String
    ): Result<ActorDetails> = withContext(ioDispatcher) {
        var localDetails = moviesLocalDataSource.getActorDetails(actorId)

        if (localDetails == null) {
            val detailsResult = moviesRemoteDataSource.getActorDetails(actorId, language)
            detailsResult.onFailure { return@withContext Result.failure(it) }

            val knownFor = moviesRemoteDataSource.getActorMovieCredits(actorId, language)
                .mapCatching { response -> response.toKnownForStrings() }
                .getOrElse { emptyList() }

            val entity = detailsResult.getOrThrow().toEntity(knownFor)
            moviesLocalDataSource.setActorDetails(entity)
            localDetails = entity
        }

        val details = localDetails ?: return@withContext Result.failure(
            Exception("Actor details caching error!")
        )

        Result.success(details.toModel())
    }

    private suspend fun getMovieDetailsFromServer(
        movieId: Int,
        language: String
    ): Result<MovieDetailsEntity> =
        withContext(ioDispatcher) {
            moviesRemoteDataSource.getMovieDetails(movieId, language)
                .mapCatching { it.toEntity() }
        }

    private suspend fun getActorsData(
        movie: MovieDetailsEntity,
        language: String
    ): Result<List<Actor>> =
        withContext(ioDispatcher) {
//            moviesLocalDataSource.clearActors()

            if (!movie.isActorsLoaded) {
                getActorsFromServer(movie.id, language)
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
        language: String
    ): Result<List<ActorEntity>> =
        withContext(ioDispatcher) {
            runCatching {
                moviesRemoteDataSource.getActors(movieId, language)
                    .getOrThrow()
                    .map { it.toEntity() }
            }
        }

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> =
        withContext(ioDispatcher) {
            runCatching {
                moviesLocalDataSource.setFavorite(movieId, isFavorite)

                val details = moviesLocalDataSource.getMovieDetails(movieId)
                val summary = moviesLocalDataSource.getMovie(movieId)

                if (summary == null && details != null) {
                    val summaryEntity = MovieListEntity(
                        id = details.id,
                        title = details.title,
                        poster = details.poster,
                        ratings = details.ratings,
                        numberOfRatings = details.numberOfRatings,
                        minimumAge = details.minimumAge,
                        year = details.year,
                        genres = details.genres,
                        isFavorite = isFavorite
                    )
                    moviesLocalDataSource.setMovie(summaryEntity)
                }
            }
        }

    override suspend fun getFavorites(): Result<List<MovieList>> =
        withContext(ioDispatcher) {
            runCatching {
                val favoriteMovies = moviesLocalDataSource.getFavoriteMovies()
                val favoriteIds = favoriteMovies.map { it.id }.toSet()
                val detailOnlyFavorites = moviesLocalDataSource.getFavoriteMovieDetails()
                    .filterNot { favoriteIds.contains(it.id) }
                    .map { details ->
                        MovieList(
                            id = details.id,
                            title = details.title,
                            poster = details.poster,
                            ratings = details.ratings,
                            numberOfRatings = details.numberOfRatings,
                            minimumAge = details.minimumAge,
                            year = details.year,
                            genres = details.genres,
                            isFavorite = true
                        )
                    }

                favoriteMovies.map { it.toModel() } + detailOnlyFavorites
            }
        }

    override suspend fun clearAll() {
        withContext(ioDispatcher) {
            val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()

            val favoriteSummaries = if (favoriteIds.isNotEmpty()) {
                moviesLocalDataSource.getFavoriteMovies()
                    .filter { favoriteIds.contains(it.id) }
                    .map { favorite ->
                        if (favorite.isFavorite) favorite else favorite.copy(isFavorite = true)
                    }
            } else {
                emptyList()
            }

            val favoriteDetails = if (favoriteIds.isNotEmpty()) {
                moviesLocalDataSource.getFavoriteMovieDetails()
                    .filter { favoriteIds.contains(it.id) }
                    .map { details ->
                        if (details.isFavorite) details else details.copy(isFavorite = true)
                    }
            } else {
                emptyList()
            }

            moviesLocalDataSource.clearConfiguration()
            moviesLocalDataSource.clearGenres()
            moviesLocalDataSource.clearNowPlaying()
            moviesLocalDataSource.clearMovieDetails()
            moviesLocalDataSource.clearActors()
            moviesLocalDataSource.clearActorDetails()

            if (favoriteSummaries.isNotEmpty()) {
                favoriteSummaries.forEach { summary ->
                    moviesLocalDataSource.setMovie(summary)
                }
            }

            if (favoriteDetails.isNotEmpty()) {
                favoriteDetails.forEach { details ->
                    moviesLocalDataSource.setMovieDetails(details)
                }
            }
        }
    }

    override suspend fun refreshLibrary(
        language: String,
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
                val existingSummary = moviesLocalDataSource.getMovie(movie.id)

                val movieDetails = getMovieDetailsFromServer(movie.id, language).getOrThrow()
                val actors = getActorsFromServer(movie.id, language).getOrThrow()
                val videos = moviesRemoteDataSource.getVideos(movie.id, language)
                    .getOrDefault(emptyList())
                val trailerUrl = videos.toPreferredTrailerUrl()
                val favoriteIds = moviesLocalDataSource.getFavoriteMovieIds()
                val isFavorite = favoriteIds.contains(movie.id) ||
                    existingDetails?.isFavorite == true ||
                    existingSummary?.isFavorite == true

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
                    notes = existingDetails?.notes.orEmpty(),
                    isFavorite = isFavorite
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
                    genres = detailsToSave.genres,
                    isFavorite = isFavorite
                )
                moviesLocalDataSource.setMovie(summaryEntity)

                onProgress(index + 1, total, movie.title)
            }
        }
    }

}
