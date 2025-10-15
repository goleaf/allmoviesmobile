package dev.tutushkin.allmovies.presentation.imdb.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.MovieDetails

sealed class ImdbImportState {
    object Loading : ImdbImportState()
    data class Ready(val movie: MovieDetails) : ImdbImportState()
    data class Imported(val movie: MovieDetails) : ImdbImportState()
    data class Error(val throwable: Throwable) : ImdbImportState()
}
