package dev.tutushkin.allmovies.presentation.moviedetails.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.presentation.common.UiText

sealed class MovieDetailsState {
    object Loading : MovieDetailsState()
    data class Result(val movie: MovieDetails) : MovieDetailsState()
    data class Error(val message: UiText) : MovieDetailsState()
}
