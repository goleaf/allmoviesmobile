package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ActorMovieCreditDto(
    @SerialName("id")
    val id: Int,
    @SerialName("title")
    val title: String? = null,
    @SerialName("original_title")
    val originalTitle: String? = null,
    @SerialName("name")
    val name: String? = null,
    @SerialName("original_name")
    val originalName: String? = null,
    @SerialName("character")
    val character: String? = null,
    @SerialName("job")
    val job: String? = null,
    @SerialName("poster_path")
    val posterPath: String? = null,
    @SerialName("release_date")
    val releaseDate: String? = null,
    @SerialName("media_type")
    val mediaType: String? = null,
    @SerialName("popularity")
    val popularity: Double? = null,
)
