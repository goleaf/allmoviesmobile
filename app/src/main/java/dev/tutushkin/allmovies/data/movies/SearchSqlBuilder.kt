package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.domain.movies.models.SearchFilters
import dev.tutushkin.allmovies.domain.movies.models.SearchRequest
import dev.tutushkin.allmovies.domain.movies.models.SortOrder
import dev.tutushkin.allmovies.domain.movies.models.TriState

internal data class SearchSql(
    val query: String,
    val queryArgs: List<Any>,
    val countQuery: String,
    val countArgs: List<Any>
)

internal object SearchSqlBuilder {

    private const val BASE_SELECT =
        "SELECT m.* FROM movies m LEFT JOIN movie_details d ON d.id = m.id"

    fun build(request: SearchRequest): SearchSql {
        val filters = request.filters
        val whereParts = mutableListOf<String>()
        val args = mutableListOf<Any>()

        appendQueryFilter(filters, whereParts, args)
        appendCategoryFilter(filters, whereParts, args)
        appendFormatFilter(filters, whereParts, args)
        appendTypeFilter(filters, whereParts)
        appendTriStateFilter("m.is_seen", filters.seen, whereParts)
        appendTriStateFilter("m.is_owned", filters.owned, whereParts)
        appendTriStateFilter("m.is_favourite", filters.favourite, whereParts)
        appendAgeRatings(filters, whereParts, args)

        val whereClause = if (whereParts.isEmpty()) {
            ""
        } else {
            " WHERE " + whereParts.joinToString(separator = " AND ")
        }

        val orderClause = buildOrderClause(request.sortOrder)
        val baseQuery = BASE_SELECT + whereClause
        val paginatedQuery = baseQuery + orderClause + " LIMIT ? OFFSET ?"
        val paginationArgs = args + listOf(
            request.pagination.pageSize,
            request.pagination.page * request.pagination.pageSize
        )

        val countQuery = BASE_SELECT + whereClause

        return SearchSql(
            query = paginatedQuery,
            queryArgs = paginationArgs,
            countQuery = "SELECT COUNT(*) FROM (" + countQuery + ") AS search_results",
            countArgs = args
        )
    }

    private fun appendQueryFilter(
        filters: SearchFilters,
        whereParts: MutableList<String>,
        args: MutableList<Any>
    ) {
        val query = filters.query.trim()
        if (query.isBlank()) return

        val normalized = "%${query.lowercase()}%"
        whereParts += "(LOWER(m.title) LIKE ? OR LOWER(m.year) LIKE ? OR LOWER(COALESCE(d.overview, m.plot)) LIKE ?)"
        repeat(3) { args += normalized }
    }

    private fun appendCategoryFilter(
        filters: SearchFilters,
        whereParts: MutableList<String>,
        args: MutableList<Any>
    ) {
        if (filters.categories.isEmpty()) return

        val clause = filters.categories.joinToString(
            separator = " OR ",
            prefix = "(",
            postfix = ")"
        ) { "m.genre_ids LIKE ?" }

        filters.categories.forEach { args += "%,${it},%" }
        whereParts += clause
    }

    private fun appendFormatFilter(
        filters: SearchFilters,
        whereParts: MutableList<String>,
        args: MutableList<Any>
    ) {
        if (filters.formats.isEmpty()) return

        val clause = filters.formats.joinToString(
            separator = " OR ",
            prefix = "(",
            postfix = ")"
        ) { "m.format = ?" }
        filters.formats.forEach { args += it }
        whereParts += clause
    }

    private fun appendTypeFilter(filters: SearchFilters, whereParts: MutableList<String>) {
        if (filters.includeMovies && filters.includeTv) return
        if (filters.includeMovies) {
            whereParts += "m.is_tv_show = 0"
        } else if (filters.includeTv) {
            whereParts += "m.is_tv_show = 1"
        }
    }

    private fun appendTriStateFilter(
        column: String,
        state: TriState,
        whereParts: MutableList<String>
    ) {
        when (state) {
            TriState.ANY -> Unit
            TriState.ENABLED -> whereParts += "$column = 1"
            TriState.DISABLED -> whereParts += "$column = 0"
        }
    }

    private fun appendAgeRatings(
        filters: SearchFilters,
        whereParts: MutableList<String>,
        args: MutableList<Any>
    ) {
        if (filters.ageRatings.isEmpty()) return
        val clause = filters.ageRatings.joinToString(
            separator = " OR ",
            prefix = "(",
            postfix = ")"
        ) { "m.age_rating = ?" }
        filters.ageRatings.forEach { args += it }
        whereParts += clause
    }

    private fun buildOrderClause(sortOrder: SortOrder): String = when (sortOrder) {
        SortOrder.NAME_ASC -> " ORDER BY m.title COLLATE NOCASE ASC"
        SortOrder.NAME_DESC -> " ORDER BY m.title COLLATE NOCASE DESC"
        SortOrder.YEAR_ASC -> " ORDER BY m.year ASC"
        SortOrder.YEAR_DESC -> " ORDER BY m.year DESC"
        SortOrder.RATING_ASC -> " ORDER BY m.ratings ASC"
        SortOrder.RATING_DESC -> " ORDER BY m.ratings DESC"
        SortOrder.VOTES_ASC -> " ORDER BY m.numberOfRatings ASC"
        SortOrder.VOTES_DESC -> " ORDER BY m.numberOfRatings DESC"
        SortOrder.FORMAT_ASC -> " ORDER BY m.format COLLATE NOCASE ASC"
        SortOrder.ADDED_DATE_DESC -> " ORDER BY m.added_date DESC"
        SortOrder.LOANED_DATE_DESC -> " ORDER BY m.loaned_date DESC"
    }
}
