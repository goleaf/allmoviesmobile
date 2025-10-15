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

    private val _searchState = MutableLiveData<MoviesSearchState>(MoviesSearchState.Idle)
    val searchState: LiveData<MoviesSearchState> = _searchState

    private var currentLanguage: String = languagePreferences.getSelectedLanguage()
    private var cachedMovies: List<MovieList> = emptyList()
    private var currentSearchQuery: String = ""

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
            requerySearch()
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
            requerySearch()
            onResult?.invoke(true)
        }
    }

    fun observeSearch(query: String) {
        val normalized = query.trim()
        currentSearchQuery = normalized

        if (normalized.isEmpty()) {
            _searchState.value = MoviesSearchState.Idle
            return
        }

        _searchState.value = MoviesSearchState.Loading
        val nextState = try {
            runSearch(normalized)
        } catch (throwable: Throwable) {
            MoviesSearchState.Error(normalized, throwable)
        }

        if (nextState !is MoviesSearchState.Loading) {
            _searchState.value = nextState
        }
    }

    private fun requerySearch() {
        val query = currentSearchQuery
        if (query.isBlank()) {
            return
        }

        _searchState.value = try {
            runSearch(query)
        } catch (throwable: Throwable) {
            MoviesSearchState.Error(query, throwable)
        }
    }

    private fun runSearch(query: String): MoviesSearchState {
        val moviesState = _movies.value
        if (cachedMovies.isEmpty()) {
            return when (moviesState) {
                null -> MoviesSearchState.Loading
                is MoviesState.Loading -> MoviesSearchState.Loading
                is MoviesState.Error -> throw moviesState.e
                else -> MoviesSearchState.Empty(query)
            }
        }

        val matches = cachedMovies.filter { movie ->
            movie.title.contains(query, ignoreCase = true)
        }

        return if (matches.isEmpty()) {
            MoviesSearchState.Empty(query)
        } else {
            MoviesSearchState.Result(query, matches)
        }
    }
}