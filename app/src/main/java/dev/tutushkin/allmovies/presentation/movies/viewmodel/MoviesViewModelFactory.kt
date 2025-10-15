package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository

class MoviesViewModelFactory(
    private val repository: MoviesRepository,
    private val languagePreferences: LanguagePreferences
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MoviesViewModel::class.java)) {
            return MoviesViewModel(repository, languagePreferences) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}