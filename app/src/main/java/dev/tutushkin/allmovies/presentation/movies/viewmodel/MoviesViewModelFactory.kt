package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.data.settings.LanguagePreferencesDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier
import dev.tutushkin.allmovies.utils.logging.Logger

class MoviesViewModelFactory(
    private val repository: MoviesRepository,
    private val languagePreferences: LanguagePreferencesDataSource,
    private val favoritesUpdateNotifier: FavoritesUpdateNotifier,
    private val logger: Logger
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MoviesViewModel::class.java)) {
            return MoviesViewModel(
                repository,
                languagePreferences,
                favoritesUpdateNotifier,
                logger
            ) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}