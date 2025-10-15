package dev.tutushkin.allmovies.data.imdb.remote

import retrofit2.http.GET
import retrofit2.http.Query

interface ImdbApi {

    @GET("/")
    suspend fun searchMovies(
        @Query("s") query: String,
        @Query("apikey") apiKey: String,
        @Query("type") type: String = "movie",
        @Query("page") page: Int = 1
    ): ImdbSearchResponse

    @GET("/")
    suspend fun getMovieDetails(
        @Query("i") imdbId: String,
        @Query("apikey") apiKey: String,
        @Query("plot") plot: String = "full"
    ): ImdbMovieDetailDto
}
