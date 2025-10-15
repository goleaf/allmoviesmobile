package dev.tutushkin.allmovies.presentation.responsivegrid

import android.app.Activity
import androidx.core.view.WindowInsetsCompat
import androidx.window.layout.WindowMetricsCalculator

/**
 * Provides responsive grid specifications using the current window metrics.
 */
class ResponsiveGridProvider(
    private val activity: Activity,
    private val calculator: ResponsiveGridCalculator,
    private val windowMetricsCalculator: WindowMetricsCalculator = WindowMetricsCalculator.getOrCreate(),
) {

    fun calculate(): ResponsiveGridSpec {
        val windowMetrics = windowMetricsCalculator.computeCurrentWindowMetrics(activity)
        val insets = windowMetrics.windowInsets
        val systemInsets = insets.getInsets(WindowInsetsCompat.Type.systemBars())
        val availableWidth = windowMetrics.bounds.width() - systemInsets.left - systemInsets.right
        return calculator.calculate(availableWidth)
    }
}
