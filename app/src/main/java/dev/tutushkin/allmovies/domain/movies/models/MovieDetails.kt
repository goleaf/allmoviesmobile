package dev.tutushkin.allmovies.domain.movies.models

data class MovieDetails(
    val id: Int = 0,
    val title: String = "",
    val overview: String = "",
    val poster: String = "",
    val backdrop: String = "",
    val ratings: Float = 0.0f,
    val numberOfRatings: Int,
    val minimumAge: String = "",    // TODO Correct values
    val year: String = "",   // TODO Add to screen
    val runtime: Int = 0,
    val genres: String = "",
    val imdbId: String = "",
    val trailerUrl: String = "",
    val loanedTo: String = "",
    val loanedSince: String = "",
    val loanDue: String = "",
    val loanStatus: String = "",
    val loanNotes: String = "",
    val notes: String = "",
    val actors: List<Actor> = listOf(),
    val isFavorite: Boolean = false,
)
