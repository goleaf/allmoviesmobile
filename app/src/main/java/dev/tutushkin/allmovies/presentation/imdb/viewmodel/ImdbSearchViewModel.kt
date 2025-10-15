package dev.tutushkin.allmovies.presentation.imdb.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import kotlinx.coroutines.launch

class ImdbSearchViewModel(
    private val repository: MoviesRepository,
    private val imdbApiKey: String
) : ViewModel() {

    private val _state = MutableLiveData<ImdbSearchState>(ImdbSearchState.Idle)
    val state: LiveData<ImdbSearchState> = _state

    fun search(query: String) {
        val formattedQuery = query.trim()
        if (formattedQuery.isEmpty()) {
            _state.value = ImdbSearchState.Idle
            return
        }

        viewModelScope.launch {
            _state.value = ImdbSearchState.Loading
            val result = repository.searchImdb(formattedQuery, imdbApiKey)
            _state.value = if (result.isSuccess) {
                ImdbSearchState.Results(result.getOrThrow())
            } else {
                ImdbSearchState.Error(
                    result.exceptionOrNull() ?: IllegalStateException("Unknown error")
                )
            }
        }
    }
}

class ImdbSearchViewModelFactory(
    private val repository: MoviesRepository,
    private val imdbApiKey: String
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ImdbSearchViewModel::class.java)) {
            return ImdbSearchViewModel(repository, imdbApiKey) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
