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

    private fun refreshMovies(clearCache: Boolean) {
        val language = currentLanguage
        viewModelScope.launch {
            _movies.value = MoviesState.Loading

            if (clearCache) {
                clearCachesPreservingFavorites()
            }

            handleLoadApiConfiguration(language)
            handleGenres(language)

            _movies.value = handleMoviesNowPlaying(language)
        }
    }

    private suspend fun clearCachesPreservingFavorites() {
        moviesRepository.clearAll()
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
            MoviesState.Result(movies)
        } else {
            cachedMovies = emptyList()
            MoviesState.Error(IllegalArgumentException("Error loading movies from the server!"))
        }
    }

    fun toggleFavorite(
        movieId: Int,
        isFavorite: Boolean,
        onResult: ((Boolean) -> Unit)? = null
    ) {
        viewModelScope.launch {
            val result = moviesRepository.setFavorite(movieId, isFavorite)
            if (result.isFailure) {
                onResult?.invoke(false)
                return@launch
            }

            val updated = cachedMovies.map { movie ->
                if (movie.id == movieId) movie.copy(isFavorite = isFavorite) else movie
            }
            cachedMovies = updated
            _movies.value = MoviesState.Result(updated)
            onResult?.invoke(true)
        }
    }
}