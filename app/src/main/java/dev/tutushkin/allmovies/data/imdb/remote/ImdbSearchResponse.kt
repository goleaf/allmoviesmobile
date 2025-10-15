package dev.tutushkin.allmovies.data.imdb.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ImdbSearchResponse(
    @SerialName("Search")
    val results: List<ImdbSearchItemDto>? = emptyList(),
    @SerialName("totalResults")
    val totalResults: String? = null,
    @SerialName("Response")
    val response: String = "False",
    @SerialName("Error")
    val error: String? = null
) {
    val isSuccessful: Boolean get() = response.equals("True", ignoreCase = true)
}

@Serializable
data class ImdbSearchItemDto(
    @SerialName("Title")
    val title: String = "",
    @SerialName("Year")
    val year: String = "",
    @SerialName("imdbID")
    val imdbId: String = "",
    @SerialName("Type")
    val type: String = "",
    @SerialName("Poster")
    val poster: String = ""
)
