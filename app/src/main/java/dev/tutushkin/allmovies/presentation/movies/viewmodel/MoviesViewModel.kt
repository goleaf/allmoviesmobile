package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.core.network.NetworkModule.allGenres
import dev.tutushkin.allmovies.data.core.network.NetworkModule.configApi
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import kotlinx.coroutines.launch

class MoviesViewModel(
    private val moviesRepository: MoviesRepository,
    private val languagePreferences: LanguagePreferences
) : ViewModel() {

    private val _movies = MutableLiveData<MoviesState>()
    val movies: LiveData<MoviesState> = _movies

    private var currentLanguage: String = languagePreferences.getSelectedLanguage()
    private var cachedMovies: List<MovieList> = emptyList()
    private var displayedMovies: List<MovieList> = emptyList()

    init {
        refreshMovies(clearCache = true)
    }

    fun changeLanguage(code: String) {
        if (code == currentLanguage) {
            return
        }

        currentLanguage = code
        refreshMovies(clearCache = true)
    }

    fun refreshMovies(clearCache: Boolean = false) {
        val language = currentLanguage
        viewModelScope.launch {
            _movies.value = MoviesState.Loading

            if (clearCache) {
                moviesRepository.clearAll()
            }

            handleLoadApiConfiguration(language)
            handleGenres(language)

            _movies.value = handleMoviesNowPlaying(language)
        }
    }

    private suspend fun handleLoadApiConfiguration(language: String) {
        val conf = moviesRepository.getConfiguration(BuildConfig.API_KEY, language)

        if (conf.isSuccess) {
            configApi = conf.getOrThrow()
        } else {
            println(conf.exceptionOrNull())
        }
    }

    private suspend fun handleGenres(language: String) {
        val genres = moviesRepository.getGenres(BuildConfig.API_KEY, language)

        if (genres.isSuccess) {
            allGenres = genres.getOrThrow()
        } else {
            println(genres.exceptionOrNull())
        }
    }

    private suspend fun handleMoviesNowPlaying(language: String): MoviesState {
        val moviesResult = moviesRepository.getNowPlaying(BuildConfig.API_KEY, language)

        return if (moviesResult.isSuccess) {
            val movies = moviesResult.getOrThrow()
            cachedMovies = movies
            displayedMovies = movies
            if (movies.isEmpty()) {
                MoviesState.Empty(MoviesState.EmptyReason.NOW_PLAYING)
            } else {
                MoviesState.Result(movies)
            }
        } else {
            cachedMovies = emptyList()
            displayedMovies = emptyList()
            MoviesState.Error(IllegalArgumentException("Error loading movies from the server!"))
        }
    }

    fun search(query: String) {
        val trimmed = query.trim()

        if (trimmed.isBlank()) {
            displayedMovies = cachedMovies
            _movies.value = if (cachedMovies.isEmpty()) {
                MoviesState.Empty(MoviesState.EmptyReason.NOW_PLAYING)
            } else {
                MoviesState.Result(cachedMovies)
            }
            return
        }

        val language = currentLanguage
        viewModelScope.launch {
            _movies.value = MoviesState.Searching(trimmed)
            val result = moviesRepository.searchMovies(BuildConfig.API_KEY, language, trimmed)

            _movies.value = if (result.isSuccess) {
                val movies = result.getOrThrow()
                displayedMovies = movies
                if (movies.isEmpty()) {
                    MoviesState.Empty(MoviesState.EmptyReason.SEARCH, trimmed)
                } else {
                    MoviesState.Result(movies)
                }
            } else {
                MoviesState.Error(result.exceptionOrNull() ?: IllegalStateException("Search failed"))
            }
        }
    }

    fun toggleFavorite(movieId: Int, isFavorite: Boolean) {
        viewModelScope.launch {
            val result = moviesRepository.setFavorite(movieId, isFavorite)
            if (result.isFailure) {
                return@launch
            }

            val updatedCached = cachedMovies.map { movie ->
                if (movie.id == movieId) movie.copy(isFavorite = isFavorite) else movie
            }
            cachedMovies = updatedCached

            val updatedDisplayed = displayedMovies.map { movie ->
                if (movie.id == movieId) movie.copy(isFavorite = isFavorite) else movie
            }
            displayedMovies = updatedDisplayed

            if (updatedDisplayed.isEmpty()) {
                _movies.value = MoviesState.Empty(MoviesState.EmptyReason.NOW_PLAYING)
            } else {
                _movies.value = MoviesState.Result(updatedDisplayed)
            }
        }
    }
}