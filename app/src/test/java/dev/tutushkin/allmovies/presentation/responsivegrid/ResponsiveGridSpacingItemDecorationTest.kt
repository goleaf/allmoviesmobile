package dev.tutushkin.allmovies.presentation.responsivegrid

import android.content.Context
import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ResponsiveGridSpacingItemDecorationTest {

    private val spacingPx = 40
    private val decoration = ResponsiveGridSpacingItemDecoration(spacingPx)

    @Test
    fun `applies equal spacing to all sides`() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val recyclerView = RecyclerView(context)
        val view = View(context)
        val outRect = Rect()

        decoration.getItemOffsets(outRect, view, recyclerView, RecyclerView.State())

        val expected = spacingPx / 2
        assertEquals(expected, outRect.left)
        assertEquals(expected, outRect.top)
        assertEquals(expected, outRect.right)
        assertEquals(expected, outRect.bottom)
    }
}
