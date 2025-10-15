package dev.tutushkin.allmovies.domain.movies.models

data class PersonalNote(
    val movieId: Int,
    val note: String,
    val updatedAt: Long
)
