package dev.tutushkin.allmovies.domain.movies.models

data class SearchFilters(
    val query: String = "",
    val categories: Set<Int> = emptySet(),
    val formats: Set<String> = emptySet(),
    val includeMovies: Boolean = true,
    val includeTv: Boolean = true,
    val seen: TriState = TriState.ANY,
    val owned: TriState = TriState.ANY,
    val favourite: TriState = TriState.ANY,
    val ageRatings: Set<String> = emptySet()
)

data class SearchPagination(
    val page: Int = 0,
    val pageSize: Int = 20
)

enum class SortOrder {
    NAME_ASC,
    NAME_DESC,
    YEAR_ASC,
    YEAR_DESC,
    RATING_ASC,
    RATING_DESC,
    VOTES_ASC,
    VOTES_DESC,
    FORMAT_ASC,
    ADDED_DATE_DESC,
    LOANED_DATE_DESC
}

enum class LayoutMode {
    POSTER,
    GRID,
    LIST,
    BACKDROP,
    COMPACT
}

enum class TriState {
    ANY,
    ENABLED,
    DISABLED
}

data class SearchRequest(
    val filters: SearchFilters = SearchFilters(),
    val sortOrder: SortOrder = SortOrder.NAME_ASC,
    val pagination: SearchPagination = SearchPagination()
)

data class SearchResult(
    val items: List<MovieList> = emptyList(),
    val totalCount: Int = 0
)
