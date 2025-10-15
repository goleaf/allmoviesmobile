package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class FindResponse(
    @SerialName("movie_results")
    val movieResults: List<FindResultDto>
)

@Serializable
data class FindResultDto(
    @SerialName("id")
    val id: Int,
    @SerialName("title")
    val title: String,
    @SerialName("overview")
    val overview: String = "",
    @SerialName("poster_path")
    val posterPath: String? = null,
    @SerialName("release_date")
    val releaseDate: String = ""
)
