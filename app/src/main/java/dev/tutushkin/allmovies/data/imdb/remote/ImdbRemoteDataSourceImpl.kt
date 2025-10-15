package dev.tutushkin.allmovies.data.imdb.remote

class ImdbRemoteDataSourceImpl(
    private val imdbApi: ImdbApi
) : ImdbRemoteDataSource {

    override suspend fun searchMovies(query: String, apiKey: String): Result<List<ImdbSearchItemDto>> =
        runCatching {
            val response = imdbApi.searchMovies(query, apiKey)
            if (!response.isSuccessful) {
                throw IllegalStateException(response.error ?: "Unable to load search results")
            }
            response.results ?: emptyList()
        }

    override suspend fun getMovieDetails(imdbId: String, apiKey: String): Result<ImdbMovieDetailDto> =
        runCatching {
            val response = imdbApi.getMovieDetails(imdbId, apiKey)
            if (!response.isSuccessful) {
                throw IllegalStateException(response.error ?: "Unable to load movie details")
            }
            response
        }
}
