package dev.tutushkin.allmovies.presentation.actors.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.ActorDetails

sealed class ActorDetailsState {
    object Loading : ActorDetailsState()
    data class Result(val details: ActorDetails) : ActorDetailsState()
    data class Error(val throwable: Throwable) : ActorDetailsState()
}
