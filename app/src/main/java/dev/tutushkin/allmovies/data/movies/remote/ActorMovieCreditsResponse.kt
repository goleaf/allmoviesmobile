package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ActorMovieCreditsResponse(
    @SerialName("id")
    val id: Int,
    @SerialName("cast")
    val cast: List<ActorMovieCreditDto> = emptyList(),
    @SerialName("crew")
    val crew: List<ActorMovieCreditDto> = emptyList(),
)
