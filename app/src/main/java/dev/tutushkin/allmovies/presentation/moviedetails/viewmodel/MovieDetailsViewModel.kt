package dev.tutushkin.allmovies.presentation.moviedetails.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class MovieDetailsViewModel(
    private val moviesRepository: MoviesRepository,
    private val id: Int,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _currentMovie = MutableLiveData<MovieDetailsState>()
    val currentMovie: LiveData<MovieDetailsState> = _currentMovie

    init {
        viewModelScope.launch {
            settingsRepository.settings.collectLatest { settings ->
                _currentMovie.value = MovieDetailsState.Loading
                _currentMovie.value = handleMovieDetails(settings.castLimit)
            }
        }
    }

    private suspend fun handleMovieDetails(castLimit: Int): MovieDetailsState {
        val movieDetails = moviesRepository.getMovieDetails(id, BuildConfig.API_KEY)

        return if (movieDetails.isSuccess) {
            val movie = movieDetails.getOrThrow()
            val limitedActors = movie.actors.take(castLimit.coerceAtLeast(0))
            MovieDetailsState.Result(movie.copy(actors = limitedActors))
        } else {
            MovieDetailsState.Error(Exception("Error loading movie details from the server!"))
        }
    }

}
