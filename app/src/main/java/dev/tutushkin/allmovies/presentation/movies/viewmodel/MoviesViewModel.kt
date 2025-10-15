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
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MoviesViewModel(
    private val moviesRepository: MoviesRepository,
    private val languagePreferences: LanguagePreferences,
    private val favoritesUpdateNotifier: FavoritesUpdateNotifier
) : ViewModel() {

    private val _movies = MutableLiveData<MoviesState>()
    val movies: LiveData<MoviesState> = _movies

    private val _searchState = MutableLiveData<MoviesSearchState>(MoviesSearchState.Idle)
    val searchState: LiveData<MoviesSearchState> = _searchState

    private var currentLanguage: String = languagePreferences.getSelectedLanguage()
    private var cachedMovies: List<MovieList> = emptyList()
    private var lastSearchResults: List<MovieList> = emptyList()
    private var currentSearchQuery: String = ""
    private var searchJob: Job? = null

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
            favoritesUpdateNotifier.notifyFavoritesChanged()
            onResult?.invoke(true)
        }
    }

    fun observeSearch(query: String) {
        val normalized = query.trim()
        currentSearchQuery = normalized
        searchJob?.cancel()

        if (normalized.isEmpty()) {
            _searchState.value = MoviesSearchState.Idle
            lastSearchResults = emptyList()
            return
        }

        launchSearch(normalized, debounce = true)
    }

    private fun requerySearch() {
        val query = currentSearchQuery
        if (query.isBlank()) {
            return
        }

        if (searchJob?.isActive == true) {
            return
        }

        emitSearchResults(query)
    }

    private fun launchSearch(query: String, debounce: Boolean) {
        _searchState.value = MoviesSearchState.Loading
        searchJob = viewModelScope.launch {
            if (debounce) {
                delay(SEARCH_DEBOUNCE_MILLIS)
            }

            val language = currentLanguage
            val result = moviesRepository.searchMovies(
                BuildConfig.API_KEY,
                language,
                query
            )

            if (query != currentSearchQuery) {
                return@launch
            }

            if (result.isSuccess) {
                lastSearchResults = result.getOrThrow()
                emitSearchResults(query)
            } else {
                lastSearchResults = emptyList()
                _searchState.value = MoviesSearchState.Error(
                    query,
                    result.exceptionOrNull() ?: IllegalStateException("Search request failed")
                )
            }
        }
    }

    private fun emitSearchResults(query: String) {
        val reconciled = reconcileWithFavorites(lastSearchResults)
        _searchState.value = if (reconciled.isEmpty()) {
            MoviesSearchState.Empty(query)
        } else {
            MoviesSearchState.Result(query, reconciled)
        }
    }

    private fun reconcileWithFavorites(results: List<MovieList>): List<MovieList> {
        if (results.isEmpty()) {
            return results
        }

        val favoriteIds = cachedMovies.filter { it.isFavorite }.associateBy { it.id }
        if (favoriteIds.isEmpty()) {
            return results
        }

        return results.map { movie ->
            val favorite = favoriteIds[movie.id] ?: return@map movie
            if (movie.isFavorite) movie else movie.copy(isFavorite = true)
        }
    }

    companion object {
        internal const val SEARCH_DEBOUNCE_MILLIS = 300L
    }
}
