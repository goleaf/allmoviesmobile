package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.data.preferences.SearchPreferencesDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository

class SearchViewModelFactory(
    private val repository: MoviesRepository,
    private val preferencesDataSource: SearchPreferencesDataSource
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SearchViewModel::class.java)) {
            return SearchViewModel(repository, preferencesDataSource) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class ${modelClass.name}")
    }
}
