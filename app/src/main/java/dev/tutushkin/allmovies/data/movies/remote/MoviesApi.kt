package dev.tutushkin.allmovies.data.movies.remote

import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface MoviesApi {

    @GET("configuration")
    suspend fun getConfiguration(
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): ConfigurationResponse

    @GET("genre/movie/list")
    suspend fun getGenres(
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): GenresResponse

    @GET("movie/now_playing")
    suspend fun getNowPlaying(
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): MovieListResponse

    @GET("movie/{movie_id}")
    suspend fun getMovieDetails(
        @Path("movie_id") movieId: Int,
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): MovieDetailsResponse

    @GET("movie/{movie_id}/release_dates")
    suspend fun getMovieReleaseDates(
        @Path("movie_id") movieId: Int,
        @Query("api_key") apiKey: String,
    ): MovieReleaseDatesResponse

    @GET("movie/{movie_id}/credits")
    suspend fun getActors(
        @Path("movie_id") movieId: Int,
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): MovieActorsResponse

    @GET("movie/{movie_id}/videos")
    suspend fun getVideos(
        @Path("movie_id") movieId: Int,
        @Query("api_key") apiKey: String,
        @Query("language") language: String
    ): MovieVideosResponse

    @GET("search/movie")
    suspend fun searchMovies(
        @Query("api_key") apiKey: String,
        @Query("language") language: String,
        @Query("query") query: String,
        @Query("include_adult") includeAdult: Boolean,
        @Query("page") page: Int = 1,
    ): MovieListResponse

    @GET("person/{person_id}")
    suspend fun getActorDetails(
        @Path("person_id") actorId: Int,
        @Query("api_key") apiKey: String,
        @Query("language") language: String,
    ): ActorDetailsResponse

    @GET("person/{person_id}/movie_credits")
    suspend fun getActorMovieCredits(
        @Path("person_id") actorId: Int,
        @Query("api_key") apiKey: String,
        @Query("language") language: String,
    ): ActorMovieCreditsResponse
}