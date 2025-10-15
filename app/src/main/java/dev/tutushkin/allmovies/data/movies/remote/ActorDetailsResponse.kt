package dev.tutushkin.allmovies.data.movies.remote

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ActorDetailsResponse(
    @SerialName("id")
    val id: Int,
    @SerialName("name")
    val name: String,
    @SerialName("biography")
    val biography: String? = null,
    @SerialName("birthday")
    val birthday: String? = null,
    @SerialName("deathday")
    val deathday: String? = null,
    @SerialName("place_of_birth")
    val placeOfBirth: String? = null,
    @SerialName("profile_path")
    val profilePath: String? = null,
    @SerialName("known_for_department")
    val knownForDepartment: String? = null,
    @SerialName("also_known_as")
    val alsoKnownAs: List<String>? = null,
    @SerialName("imdb_id")
    val imdbId: String? = null,
    @SerialName("homepage")
    val homepage: String? = null,
    @SerialName("popularity")
    val popularity: Double? = null,
)
