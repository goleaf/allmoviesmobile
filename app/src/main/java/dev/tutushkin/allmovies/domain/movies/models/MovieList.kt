package dev.tutushkin.allmovies.domain.movies.models

// TODO Delete default value(?)
data class MovieList(
    val id: Int = 0,
    val title: String = "",
    val poster: String = "",
    val ratings: Float = 0.0f,
    val numberOfRatings: Int = 0,
    val minimumAge: String = "",
    val year: String = "",
    val genres: String = "",
    val isTvShow: Boolean = false,
    val isSeen: Boolean = false,
    val isOwned: Boolean = false,
    val isFavourite: Boolean = false,
    val format: String = DEFAULT_FORMAT,
    val ageRating: String = DEFAULT_AGE_RATING,
    val addedDate: Long = 0L,
    val loanedDate: Long = 0L,
    val plot: String = ""
)

const val DEFAULT_FORMAT = "Digital"
const val DEFAULT_AGE_RATING = "NR"
