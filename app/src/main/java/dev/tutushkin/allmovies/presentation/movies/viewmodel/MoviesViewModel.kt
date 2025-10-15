package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.core.network.NetworkModule.allGenres
import dev.tutushkin.allmovies.data.core.network.NetworkModule.configApi
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class MoviesViewModel(
    private val moviesRepository: MoviesRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _movies = MutableLiveData<MoviesState>()
    val movies: LiveData<MoviesState> = _movies

    init {
        viewModelScope.launch {
            settingsRepository.settings.collectLatest { settings ->
                _movies.value = MoviesState.Loading
                moviesRepository.clearAll()

                handleLoadApiConfiguration()
                handleGenres()

                _movies.value = handleMoviesNowPlaying(settings)
            }
        }
    }

    private suspend fun handleLoadApiConfiguration() {
        val conf = moviesRepository.getConfiguration(BuildConfig.API_KEY)

        if (conf.isSuccess) {
            configApi = conf.getOrThrow()
        } else {
            println(conf.exceptionOrNull())
        }
    }

    private suspend fun handleGenres() {
        val genres = moviesRepository.getGenres(BuildConfig.API_KEY)

        if (genres.isSuccess) {
            allGenres = genres.getOrThrow()
        } else {
            println(genres.exceptionOrNull())
        }
    }

    private suspend fun handleMoviesNowPlaying(settings: AppSettings): MoviesState {
        val page = settings.defaultPage.coerceAtLeast(1)
        val moviesResult = moviesRepository.getNowPlaying(BuildConfig.API_KEY, page)

        return if (moviesResult.isSuccess) {
            val pageSize = settings.resultsPerPage.coerceAtLeast(1)
            val movies = moviesResult.getOrThrow().take(pageSize)
            MoviesState.Result(movies)
        } else {
            MoviesState.Error(IllegalArgumentException("Error loading movies from the server!"))
        }
    }

}
