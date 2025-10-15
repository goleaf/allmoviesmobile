package dev.tutushkin.allmovies.domain.movies.models

data class ActorDetails(
    val id: Int,
    val name: String,
    val biography: String,
    val birthday: String?,
    val deathday: String?,
    val birthplace: String?,
    val profileImage: String?,
    val knownForDepartment: String?,
    val alsoKnownAs: List<String>,
    val imdbId: String?,
    val homepage: String?,
    val popularity: Double,
    val knownFor: List<String>,
)
