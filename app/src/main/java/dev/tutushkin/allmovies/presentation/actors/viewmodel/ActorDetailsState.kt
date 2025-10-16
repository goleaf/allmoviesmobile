package dev.tutushkin.allmovies.presentation.actors.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.utils.UiText

sealed class ActorDetailsState {
    object Loading : ActorDetailsState()
    data class Result(val details: ActorDetails) : ActorDetailsState()
    data class Error(val message: UiText) : ActorDetailsState()
}
