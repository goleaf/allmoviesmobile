package dev.tutushkin.allmovies.data.movies.remote

class MoviesRemoteDataSourceImpl(
    private val moviesApi: MoviesApi
) : MoviesRemoteDataSource {

    override suspend fun getConfiguration(language: String): Result<ConfigurationDto> =
        runCatching {
            moviesApi.getConfiguration(language).images
        }

    override suspend fun getGenres(language: String): Result<List<GenreDto>> =
        runCatching {
            moviesApi.getGenres(language).genres
        }

    override suspend fun getNowPlaying(language: String): Result<List<MovieListDto>> =
        runCatching {
            moviesApi.getNowPlaying(language).results
        }

    override suspend fun searchMovies(
        language: String,
        query: String,
        includeAdult: Boolean,
    ): Result<List<MovieListDto>> =
        runCatching {
            moviesApi.searchMovies(language, query, includeAdult).results
        }

    override suspend fun getMovieDetails(
        movieId: Int,
        language: String
    ): Result<MovieDetailsResponse> =
        runCatching {
            moviesApi.getMovieDetails(movieId, language)
        }

    override suspend fun getMovieReleaseDates(
        movieId: Int
    ): Result<MovieReleaseDatesResponse> =
        runCatching {
            moviesApi.getMovieReleaseDates(movieId)
        }

    override suspend fun getActors(
        movieId: Int,
        language: String
    ): Result<List<MovieActorDto>> =
        runCatching {
            moviesApi.getActors(movieId, language).cast
        }

    override suspend fun getVideos(
        movieId: Int,
        language: String
    ): Result<List<MovieVideoDto>> =
        runCatching {
            moviesApi.getVideos(movieId, language).results
        }

    override suspend fun getActorDetails(
        actorId: Int,
        language: String,
    ): Result<ActorDetailsResponse> =
        runCatching {
            moviesApi.getActorDetails(actorId, language)
        }

    override suspend fun getActorMovieCredits(
        actorId: Int,
        language: String,
    ): Result<ActorMovieCreditsResponse> =
        runCatching {
            moviesApi.getActorMovieCredits(actorId, language)
        }
}
