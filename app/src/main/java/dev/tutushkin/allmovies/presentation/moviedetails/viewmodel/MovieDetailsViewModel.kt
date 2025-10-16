package dev.tutushkin.allmovies.presentation.moviedetails.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalytics
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.utils.UiText
import kotlinx.coroutines.launch

class MovieDetailsViewModel(
    private val moviesRepository: MoviesRepository,
    private val id: Int,
    private val slug: String?,
    private val openedFromSharedLink: Boolean,
    private val analytics: SharedLinkAnalytics,
    private val language: String,
    private val moviesViewModel: MoviesViewModel
) : ViewModel() {

    private val _currentMovie = MutableLiveData<MovieDetailsState>()
    val currentMovie: LiveData<MovieDetailsState> = _currentMovie

    init {
        viewModelScope.launch {
            if (id <= 0) {
                _currentMovie.value = MovieDetailsState.Error(
                    UiText.stringResource(R.string.movie_details_error_missing_id)
                )
                return@launch
            }

            if (openedFromSharedLink) {
                analytics.logSharedLinkOpened(id, slug)
            }

            _currentMovie.value = MovieDetailsState.Loading
            _currentMovie.value = handleMovieDetails()
        }
    }

    private suspend fun handleMovieDetails(): MovieDetailsState {
        val movieDetails = moviesRepository.getMovieDetails(
            id,
            language,
            ensureCached = true
        )

        return if (movieDetails.isSuccess)
            MovieDetailsState.Result(movieDetails.getOrThrow())
        else
            MovieDetailsState.Error(UiText.stringResource(R.string.movie_details_error_generic))
    }

    fun toggleFavorite() {
        val currentState = _currentMovie.value as? MovieDetailsState.Result ?: return
        val movie = currentState.movie
        val newState = !movie.isFavorite

        moviesViewModel.toggleFavorite(movie.id, newState) { success ->
            if (success) {
                _currentMovie.value = MovieDetailsState.Result(movie.copy(isFavorite = newState))
            }
        }
    }

}