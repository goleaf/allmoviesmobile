package dev.tutushkin.allmovies.domain.movies.models

/**
 * Represents a local draft of a movie that the user is creating or editing.
 */
data class DraftMovie(
    val id: Long = 0L,
    val title: String = "",
    val titleOrder: String = "",
    val akaTitles: List<String> = emptyList(),
    val durationMinutes: Int? = null,
    val formats: List<String> = emptyList(),
    val mpaaRating: String = "",
    val cast: List<String> = emptyList(),
    val crew: List<String> = emptyList(),
    val trailerUrl: String = "",
    val releaseDate: String = "",
    val personalNotes: String = "",
    val imdbId: String? = null,
    val coverUri: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
