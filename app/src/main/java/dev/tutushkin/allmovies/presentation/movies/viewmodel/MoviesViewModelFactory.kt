package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.data.settings.LanguagePreferencesDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier

class MoviesViewModelFactory(
    private val repository: MoviesRepository,
    private val languagePreferences: LanguagePreferencesDataSource,
    private val favoritesUpdateNotifier: FavoritesUpdateNotifier
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MoviesViewModel::class.java)) {
            return MoviesViewModel(repository, languagePreferences, favoritesUpdateNotifier) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}