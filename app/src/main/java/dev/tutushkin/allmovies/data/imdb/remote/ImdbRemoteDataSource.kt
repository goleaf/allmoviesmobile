package dev.tutushkin.allmovies.data.imdb.remote

interface ImdbRemoteDataSource {

    suspend fun searchMovies(query: String, apiKey: String): Result<List<ImdbSearchItemDto>>

    suspend fun getMovieDetails(imdbId: String, apiKey: String): Result<ImdbMovieDetailDto>
}
