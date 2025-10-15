package dev.tutushkin.allmovies.presentation.actors.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import kotlinx.coroutines.launch

class ActorDetailsViewModel(
    private val moviesRepository: MoviesRepository,
    private val actorId: Int,
    private val language: String,
) : ViewModel() {

    private val _actorDetails = MutableLiveData<ActorDetailsState>()
    val actorDetails: LiveData<ActorDetailsState> = _actorDetails

    init {
        loadActorDetails()
    }

    fun retry() {
        loadActorDetails()
    }

    private fun loadActorDetails() {
        viewModelScope.launch {
            if (actorId <= 0) {
                _actorDetails.value =
                    ActorDetailsState.Error(IllegalArgumentException("Missing actor id"))
                return@launch
            }

            _actorDetails.value = ActorDetailsState.Loading
            _actorDetails.value = fetchActorDetails()
        }
    }

    private suspend fun fetchActorDetails(): ActorDetailsState {
        val result = moviesRepository.getActorDetails(
            actorId,
            language,
        )

        return if (result.isSuccess) {
            ActorDetailsState.Result(result.getOrThrow())
        } else {
            ActorDetailsState.Error(
                result.exceptionOrNull() ?: Exception("Error loading actor details from the server!"),
            )
        }
    }
}
