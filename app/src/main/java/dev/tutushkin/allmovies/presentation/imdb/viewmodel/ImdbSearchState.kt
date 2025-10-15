package dev.tutushkin.allmovies.presentation.imdb.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.ImdbSearchResult

sealed class ImdbSearchState {
    object Idle : ImdbSearchState()
    object Loading : ImdbSearchState()
    data class Results(val items: List<ImdbSearchResult>) : ImdbSearchState()
    data class Error(val throwable: Throwable) : ImdbSearchState()
}
