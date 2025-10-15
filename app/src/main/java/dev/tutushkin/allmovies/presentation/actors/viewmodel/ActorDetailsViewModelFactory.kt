package dev.tutushkin.allmovies.presentation.actors.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.domain.movies.MoviesRepository

class ActorDetailsViewModelFactory(
    private val moviesRepository: MoviesRepository,
    private val actorId: Int,
    private val language: String,
) : ViewModelProvider.Factory {

    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ActorDetailsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ActorDetailsViewModel(moviesRepository, actorId, language) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class ${modelClass.name}")
    }
}
