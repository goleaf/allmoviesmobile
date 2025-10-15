package dev.tutushkin.allmovies.domain.movies.models

data class ImdbSearchResult(
    val imdbId: String,
    val title: String,
    val year: String,
    val poster: String
)
