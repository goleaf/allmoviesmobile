package dev.tutushkin.allmovies.presentation.favorites.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

sealed class FavoritesState {
    object Loading : FavoritesState()
    data class Result(val movies: List<MovieList>) : FavoritesState()
    object Empty : FavoritesState()
    data class Error(val throwable: Throwable) : FavoritesState()
}

class FavoritesViewModel(
    private val moviesRepository: MoviesRepository,
    private val favoritesUpdateNotifier: FavoritesUpdateNotifier
) : ViewModel() {

    private val _favorites = MutableLiveData<FavoritesState>(FavoritesState.Loading)
    val favorites: LiveData<FavoritesState> = _favorites

    private var refreshJob: Job? = null

    init {
        observeUpdates()
        refreshFavorites()
    }

    fun refreshFavorites() {
        refreshJob?.cancel()
        refreshJob = viewModelScope.launch {
            if (_favorites.value !is FavoritesState.Result) {
                _favorites.value = FavoritesState.Loading
            }

            val result = moviesRepository.getFavorites()
            _favorites.value = if (result.isSuccess) {
                val movies = result.getOrThrow()
                if (movies.isEmpty()) {
                    FavoritesState.Empty
                } else {
                    FavoritesState.Result(movies)
                }
            } else {
                FavoritesState.Error(result.exceptionOrNull() ?: IllegalStateException("Failed to load favorites"))
            }
        }
    }

    private fun observeUpdates() {
        viewModelScope.launch {
            favoritesUpdateNotifier.updates.collectLatest {
                refreshFavorites()
            }
        }
    }
}
