package dev.tutushkin.allmovies.data.movies.remote

interface MoviesRemoteDataSource {

    suspend fun getConfiguration(language: String): Result<ConfigurationDto>

    suspend fun getGenres(language: String): Result<List<GenreDto>>

    suspend fun getNowPlaying(language: String): Result<List<MovieListDto>>

    suspend fun searchMovies(
        language: String,
        query: String,
        includeAdult: Boolean,
    ): Result<List<MovieListDto>>

    suspend fun getMovieDetails(
        movieId: Int,
        language: String
    ): Result<MovieDetailsResponse>

    suspend fun getMovieReleaseDates(
        movieId: Int
    ): Result<MovieReleaseDatesResponse>

    suspend fun getActors(
        movieId: Int,
        language: String
    ): Result<List<MovieActorDto>>

    suspend fun getVideos(
        movieId: Int,
        language: String
    ): Result<List<MovieVideoDto>>

    suspend fun getActorDetails(
        actorId: Int,
        language: String,
    ): Result<ActorDetailsResponse>

    suspend fun getActorMovieCredits(
        actorId: Int,
        language: String,
    ): Result<ActorMovieCreditsResponse>
}