package dev.tutushkin.allmovies.presentation.movies.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.MovieList

sealed class MoviesSearchState {
    object Idle : MoviesSearchState()
    object Loading : MoviesSearchState()
    data class Result(val query: String, val result: List<MovieList>) : MoviesSearchState()
    data class Empty(val query: String) : MoviesSearchState()
    data class Error(val query: String, val cause: Throwable) : MoviesSearchState()
}
