package dev.tutushkin.allmovies.presentation.responsivegrid

import kotlin.math.max

/**
 * Calculates responsive grid characteristics based on the available width.
 */
class ResponsiveGridCalculator(
    private val minimumCellWidthPx: Int,
    private val horizontalSpacingPx: Int,
) {

    /**
     * Calculates the span count and cell width for the provided width.
     */
    fun calculate(availableWidthPx: Int): ResponsiveGridSpec {
        val safeAvailableWidth = availableWidthPx.coerceAtLeast(0)
        val spanCount = max(
            1,
            (safeAvailableWidth + horizontalSpacingPx) / (minimumCellWidthPx + horizontalSpacingPx)
        )

        val totalSpacing = horizontalSpacingPx * spanCount
        val cellWidth = if (spanCount == 0) {
            0
        } else {
            ((safeAvailableWidth - totalSpacing) / spanCount).coerceAtLeast(0)
        }

        return ResponsiveGridSpec(spanCount, cellWidth)
    }
}
