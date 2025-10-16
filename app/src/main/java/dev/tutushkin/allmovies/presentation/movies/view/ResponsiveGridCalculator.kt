package dev.tutushkin.allmovies.presentation.movies.view

import androidx.annotation.VisibleForTesting
import androidx.window.layout.WindowMetrics
import kotlin.math.roundToInt

interface ResponsiveGridCalculator {
    fun calculate(windowMetrics: WindowMetrics, density: Float, spacingDp: Float): ResponsiveGridConfig
}

data class ResponsiveGridConfig(
    val spanCount: Int,
    val itemWidthPx: Int,
    val spacingPx: Int,
)

class ResponsiveGridCalculatorImpl : ResponsiveGridCalculator {

    override fun calculate(
        windowMetrics: WindowMetrics,
        density: Float,
        spacingDp: Float,
    ): ResponsiveGridConfig {
        return calculate(windowMetrics.bounds.width(), density, spacingDp)
    }

    @VisibleForTesting
    internal fun calculate(
        widthPx: Int,
        density: Float,
        spacingDp: Float,
    ): ResponsiveGridConfig {
        val widthDp = widthPx / density
        val spanCount = determineSpanCount(widthDp)
        val spacingPx = (spacingDp * density).roundToInt()
        val totalSpacing = spacingPx * (spanCount + 1)
        val availableWidth = (widthPx - totalSpacing).coerceAtLeast(0)
        val itemWidthPx = if (spanCount == 0) {
            0
        } else {
            (availableWidth.toFloat() / spanCount.toFloat()).roundToInt()
        }

        return ResponsiveGridConfig(spanCount, itemWidthPx, spacingPx)
    }

    private fun determineSpanCount(widthDp: Float): Int {
        val tabletBreakpoint = 840f
        val landscapeBreakpoint = 600f
        return when {
            widthDp >= tabletBreakpoint -> TABLET_SPAN_COUNT
            widthDp >= landscapeBreakpoint -> LANDSCAPE_SPAN_COUNT
            else -> PORTRAIT_SPAN_COUNT
        }
    }

    private companion object {
        private const val PORTRAIT_SPAN_COUNT = 2
        private const val LANDSCAPE_SPAN_COUNT = 3
        private const val TABLET_SPAN_COUNT = 4
    }
}
