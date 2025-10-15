package dev.tutushkin.allmovies.presentation.responsivegrid

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

/**
 * Applies even spacing around items in the responsive grid.
 */
class ResponsiveGridSpacingItemDecoration(
    private val spacingPx: Int,
) : RecyclerView.ItemDecoration() {

    private val halfSpacing = spacingPx / 2

    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State
    ) {
        outRect.set(halfSpacing, halfSpacing, halfSpacing, halfSpacing)
    }
}
