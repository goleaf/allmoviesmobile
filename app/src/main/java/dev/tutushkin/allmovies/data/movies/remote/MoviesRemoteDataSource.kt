package dev.tutushkin.allmovies.data.movies.remote

interface MoviesRemoteDataSource {

    suspend fun getConfiguration(apiKey: String, language: String): Result<ConfigurationDto>

    suspend fun getGenres(apiKey: String, language: String): Result<List<GenreDto>>

    suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieListDto>>

    suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<MovieDetailsResponse>

    suspend fun getActors(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieActorDto>>

    suspend fun getVideos(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieVideoDto>>
}