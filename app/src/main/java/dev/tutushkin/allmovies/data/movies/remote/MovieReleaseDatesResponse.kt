package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class MovieReleaseDatesResponse(
    @SerialName("results")
    val results: List<ReleaseDatesCountryDto>
)

@Serializable
data class ReleaseDatesCountryDto(
    @SerialName("iso_3166_1")
    val countryCode: String,
    @SerialName("release_dates")
    val releaseDates: List<ReleaseDateDto>
)

@Serializable
data class ReleaseDateDto(
    @SerialName("certification")
    val certification: String,
    @SerialName("iso_639_1")
    val languageCode: String? = null,
    @SerialName("note")
    val note: String? = null,
    @SerialName("release_date")
    val releaseDate: String? = null,
    @SerialName("type")
    val type: Int? = null
)
