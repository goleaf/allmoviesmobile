package dev.tutushkin.allmovies.presentation.movies.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.MovieList

sealed class MoviesState {
    object Loading : MoviesState()
    data class Searching(val query: String) : MoviesState()
    data class Result(val result: List<MovieList>) : MoviesState()
    data class Empty(val reason: EmptyReason, val query: String? = null) : MoviesState()
    data class Error(val e: Throwable) : MoviesState()

    enum class EmptyReason {
        NOW_PLAYING,
        SEARCH,
    }
}