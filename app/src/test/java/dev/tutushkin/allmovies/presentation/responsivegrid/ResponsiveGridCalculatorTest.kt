package dev.tutushkin.allmovies.presentation.responsivegrid

import org.junit.Assert.assertEquals
import org.junit.Test

class ResponsiveGridCalculatorTest {

    private val spacingPx = 32
    private val minimumCellWidthPx = 200
    private val calculator = ResponsiveGridCalculator(minimumCellWidthPx, spacingPx)

    @Test
    fun `returns single span when width is smaller than minimum`() {
        val availableWidth = 180

        val spec = calculator.calculate(availableWidth)

        assertEquals(1, spec.spanCount)
        assertEquals(availableWidth - spacingPx, spec.cellWidthPx)
    }

    @Test
    fun `calculates multiple spans when space allows`() {
        val availableWidth = 720

        val spec = calculator.calculate(availableWidth)

        assertEquals(3, spec.spanCount)
        assertEquals(208, spec.cellWidthPx)
    }

    @Test
    fun `never returns negative values`() {
        val spec = calculator.calculate(-50)

        assertEquals(1, spec.spanCount)
        assertEquals(0, spec.cellWidthPx)
    }
}
