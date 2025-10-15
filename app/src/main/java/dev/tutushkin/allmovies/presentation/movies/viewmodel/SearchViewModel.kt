package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.preferences.SearchPreferencesDataSource
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.LayoutMode
import dev.tutushkin.allmovies.domain.movies.models.SearchFilters
import dev.tutushkin.allmovies.domain.movies.models.SearchPagination
import dev.tutushkin.allmovies.domain.movies.models.SearchRequest
import dev.tutushkin.allmovies.domain.movies.models.SortOrder
import dev.tutushkin.allmovies.domain.movies.models.TriState
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class SearchViewModel(
    private val repository: MoviesRepository,
    private val preferencesDataSource: SearchPreferencesDataSource,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO
) : ViewModel() {

    private val _state = MutableStateFlow(SearchUiState())
    val state: StateFlow<SearchUiState> = _state.asStateFlow()

    init {
        observePreferences()
        viewModelScope.launch(dispatcher) {
            repository.clearAll()
            loadConfiguration()
            loadGenres()
            loadNowPlaying()
            refreshLibrary(resetPage = true)
        }
    }

    private suspend fun loadConfiguration() {
        repository.getConfiguration(BuildConfig.API_KEY)
            .onSuccess { NetworkModule.configApi = it }
    }

    private suspend fun loadGenres() {
        repository.getGenres(BuildConfig.API_KEY)
            .onSuccess { genres ->
                NetworkModule.allGenres = genres
                _state.update { current ->
                    current.copy(
                        availableGenres = genres.associate { it.id to it.name }
                    )
                }
            }
    }

    private suspend fun loadNowPlaying() {
        repository.getNowPlaying(BuildConfig.API_KEY)
    }

    private fun observePreferences() {
        viewModelScope.launch {
            preferencesDataSource.layoutModeFlow.collectLatest { layout ->
                _state.update { current -> current.copy(layoutMode = layout) }
            }
        }

        viewModelScope.launch {
            preferencesDataSource.pageSizeFlow.collectLatest { pageSize ->
                val previous = _state.value.pageSize
                _state.update { current -> current.copy(pageSize = pageSize) }
                if (previous != pageSize) {
                    refreshLibrary(resetPage = true)
                }
            }
        }
    }

    fun updateQuery(query: String) {
        val filters = _state.value.filters.copy(query = query)
        _state.update { current ->
            current.copy(query = query, filters = filters)
        }
        refreshLibrary(resetPage = true)
    }

    fun updateFilters(filters: SearchFilters) {
        _state.update { current -> current.copy(filters = filters, query = filters.query) }
        refreshLibrary(resetPage = true)
    }

    fun toggleSeenFilter(state: TriState) {
        updateFilters(_state.value.filters.copy(seen = state))
    }

    fun toggleOwnedFilter(state: TriState) {
        updateFilters(_state.value.filters.copy(owned = state))
    }

    fun toggleFavouriteFilter(state: TriState) {
        updateFilters(_state.value.filters.copy(favourite = state))
    }

    fun setSortOrder(sortOrder: SortOrder) {
        if (_state.value.sortOrder == sortOrder) return
        _state.update { current -> current.copy(sortOrder = sortOrder) }
        refreshLibrary(resetPage = true)
    }

    fun setLayoutMode(layoutMode: LayoutMode) {
        viewModelScope.launch { preferencesDataSource.setLayoutMode(layoutMode) }
    }

    fun setPageSize(pageSize: Int) {
        viewModelScope.launch { preferencesDataSource.setPageSize(pageSize) }
    }

    fun loadPage(page: Int) {
        refreshLibrary(resetPage = false, page = page)
    }

    private fun refreshLibrary(resetPage: Boolean, page: Int = if (resetPage) 0 else _state.value.page) {
        viewModelScope.launch(dispatcher) {
            _state.update { current -> current.copy(isLoading = true, errorMessage = null) }
            val request = SearchRequest(
                filters = _state.value.filters,
                sortOrder = _state.value.sortOrder,
                pagination = SearchPagination(page = page, pageSize = _state.value.pageSize)
            )

            repository.searchLibrary(request)
                .onSuccess { result ->
                    _state.update { current ->
                        current.copy(
                            isLoading = false,
                            results = result.items,
                            totalCount = result.totalCount,
                            page = page,
                            errorMessage = null
                        )
                    }
                }
                .onFailure { throwable ->
                    _state.update { current ->
                        current.copy(
                            isLoading = false,
                            errorMessage = throwable.message
                                ?: "Unable to load library"
                        )
                    }
                }
        }
    }
}
