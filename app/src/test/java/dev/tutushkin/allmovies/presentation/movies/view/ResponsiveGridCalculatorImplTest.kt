package dev.tutushkin.allmovies.presentation.movies.view

import org.junit.Assert.assertEquals
import org.junit.Test

class ResponsiveGridCalculatorImplTest {

    private val calculator = ResponsiveGridCalculatorImpl()

    @Test
    fun phonePortraitUsesTwoColumns() {
        val result = calculator.calculate(widthPx = 1080, density = 3f, spacingDp = 12f)

        assertEquals(2, result.spanCount)
        assertEquals(486, result.itemWidthPx)
    }

    @Test
    fun phoneLandscapeUsesThreeColumns() {
        val result = calculator.calculate(widthPx = 1920, density = 3f, spacingDp = 12f)

        assertEquals(3, result.spanCount)
        assertEquals(592, result.itemWidthPx)
    }

    @Test
    fun tabletWidthUsesFourColumns() {
        val result = calculator.calculate(widthPx = 2048, density = 2f, spacingDp = 12f)

        assertEquals(4, result.spanCount)
        assertEquals(482, result.itemWidthPx)
    }
}
