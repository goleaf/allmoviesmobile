package dev.tutushkin.allmovies.presentation.favorites.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier

class FavoritesViewModelFactory(
    private val repository: MoviesRepository,
    private val favoritesUpdateNotifier: FavoritesUpdateNotifier
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(FavoritesViewModel::class.java)) {
            return FavoritesViewModel(repository, favoritesUpdateNotifier) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
