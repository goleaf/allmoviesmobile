package dev.tutushkin.allmovies.domain.movies.models

data class MovieDetails(
    val id: Int = 0,
    val title: String = "",
    val overview: String = "",
    val backdrop: String = "",
    val ratings: Float = 0.0f,
    val numberOfRatings: Int,
    val minimumAge: String = "",    // TODO Correct values
    val year: String = "",   // TODO Add to screen
    val runtime: Int = 0,
    val genres: String = "",
    val actors: List<Actor> = listOf(),
    val directors: List<String> = emptyList(),
    val writers: List<String> = emptyList(),
    val languages: List<String> = emptyList(),
    val subtitles: List<String> = emptyList(),
    val audioTracks: List<String> = emptyList(),
    val videoFormats: List<String> = emptyList(),
    val trailerUrls: List<String> = emptyList()
)
