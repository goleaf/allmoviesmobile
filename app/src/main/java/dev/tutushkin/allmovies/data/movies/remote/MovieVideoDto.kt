package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class MovieVideoDto(
    @SerialName("id")
    val id: String,
    @SerialName("key")
    val key: String,
    @SerialName("name")
    val name: String,
    @SerialName("site")
    val site: String,
    @SerialName("type")
    val type: String,
    @SerialName("official")
    val official: Boolean = false
)
