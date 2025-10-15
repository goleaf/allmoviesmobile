package dev.tutushkin.allmovies.data.movies.remote

class MoviesRemoteDataSourceImpl(
    private val moviesApi: MoviesApi
) : MoviesRemoteDataSource {

    override suspend fun getConfiguration(apiKey: String, language: String): Result<ConfigurationDto> =
        runCatching {
            moviesApi.getConfiguration(apiKey, language).images
        }

    override suspend fun getGenres(apiKey: String, language: String): Result<List<GenreDto>> =
        runCatching {
            moviesApi.getGenres(apiKey, language).genres
        }

    override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieListDto>> =
        runCatching {
            moviesApi.getNowPlaying(apiKey, language).results
        }

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<MovieDetailsResponse> =
        runCatching {
            moviesApi.getMovieDetails(movieId, apiKey, language)
        }

    override suspend fun getActors(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieActorDto>> =
        runCatching {
            moviesApi.getActors(movieId, apiKey, language).cast
        }

    override suspend fun getVideos(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieVideoDto>> =
        runCatching {
            moviesApi.getVideos(movieId, apiKey, language).results
        }

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String,
        includeAdult: Boolean,
        page: Int?
    ): Result<List<MovieListDto>> =
        runCatching {
            moviesApi.searchMovies(apiKey, language, query, includeAdult, page).results
        }
}
