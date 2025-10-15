package dev.tutushkin.allmovies.presentation.responsivegrid

/**
 * Represents the calculated grid configuration for responsive layouts.
 *
 * @property spanCount number of columns in the grid.
 * @property cellWidthPx width in pixels for every cell in the grid.
 */
data class ResponsiveGridSpec(
    val spanCount: Int,
    val cellWidthPx: Int,
)
