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
import kotlinx.coroutines.launch

class MoviesViewModel(
    private val moviesRepository: MoviesRepository,
    private val languagePreferences: LanguagePreferences
) : ViewModel() {

    private val _movies = MutableLiveData<MoviesState>()
    val movies: LiveData<MoviesState> = _movies

    private var currentLanguage: String = languagePreferences.getSelectedLanguage()

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

        return if (moviesResult.isSuccess)
            MoviesState.Result(moviesResult.getOrThrow())
        else
            MoviesState.Error(IllegalArgumentException("Error loading movies from the server!"))
    }

}