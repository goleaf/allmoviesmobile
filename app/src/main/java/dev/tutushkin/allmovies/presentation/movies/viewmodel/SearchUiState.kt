package dev.tutushkin.allmovies.presentation.movies.viewmodel

import dev.tutushkin.allmovies.domain.movies.models.LayoutMode
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.domain.movies.models.SearchFilters
import dev.tutushkin.allmovies.domain.movies.models.SortOrder

data class SearchUiState(
    val isLoading: Boolean = true,
    val results: List<MovieList> = emptyList(),
    val totalCount: Int = 0,
    val query: String = "",
    val filters: SearchFilters = SearchFilters(),
    val sortOrder: SortOrder = SortOrder.NAME_ASC,
    val layoutMode: LayoutMode = LayoutMode.POSTER,
    val pageSize: Int = 20,
    val page: Int = 0,
    val errorMessage: String? = null,
    val availableFormats: Set<String> = setOf("Digital", "Blu-ray", "DVD", "4K"),
    val availableAgeRatings: Set<String> = setOf("G", "PG", "PG-13", "R", "NC-17", "NR"),
    val availablePageSizes: List<Int> = listOf(10, 20, 50, 100),
    val availableGenres: Map<Int, String> = emptyMap()
)
