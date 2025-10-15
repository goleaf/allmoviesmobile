package dev.tutushkin.allmovies.presentation.imdb.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import kotlinx.coroutines.launch

class ImdbImportViewModel(
    private val repository: MoviesRepository,
    private val imdbApiKey: String
) : ViewModel() {

    private val _state = MutableLiveData<ImdbImportState>()
    val state: LiveData<ImdbImportState> = _state

    private var currentMovie: MovieDetails? = null

    fun load(imdbId: String) {
        viewModelScope.launch {
            _state.value = ImdbImportState.Loading
            val result = repository.getImdbMovieDetails(imdbId, imdbApiKey)
            if (result.isSuccess) {
                val movie = result.getOrThrow()
                currentMovie = movie
                _state.value = ImdbImportState.Ready(movie)
            } else {
                _state.value = ImdbImportState.Error(
                    result.exceptionOrNull() ?: IllegalStateException("Unknown error")
                )
            }
        }
    }

    fun import(imdbId: String) {
        viewModelScope.launch {
            _state.value = ImdbImportState.Loading
            val result = repository.importImdbMovie(imdbId, imdbApiKey)
            if (result.isSuccess) {
                val movie = result.getOrThrow()
                currentMovie = movie
                _state.value = ImdbImportState.Imported(movie)
            } else {
                _state.value = ImdbImportState.Error(
                    result.exceptionOrNull() ?: IllegalStateException("Unknown error")
                )
            }
        }
    }

    fun restoreLastState() {
        currentMovie?.let {
            _state.value = ImdbImportState.Ready(it)
        }
    }
}

class ImdbImportViewModelFactory(
    private val repository: MoviesRepository,
    private val imdbApiKey: String
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ImdbImportViewModel::class.java)) {
            return ImdbImportViewModel(repository, imdbApiKey) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
