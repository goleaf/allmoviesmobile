package dev.tutushkin.allmovies.presentation.movies.view

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import kotlin.math.roundToInt

class SpacingItemDecoration(
    private val spanCount: Int,
    private val spacingPx: Int,
) : RecyclerView.ItemDecoration() {

    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State,
    ) {
        val position = parent.getChildAdapterPosition(view)
        if (position == RecyclerView.NO_POSITION || spanCount <= 0) {
            return
        }

        val column = position % spanCount
        outRect.left = calculateLeftOffset(column)
        outRect.right = calculateRightOffset(column)
        if (position < spanCount) {
            outRect.top = spacingPx
        }
        outRect.bottom = spacingPx
    }

    private fun calculateLeftOffset(column: Int): Int {
        val fraction = (spanCount - column).toFloat() / spanCount.toFloat()
        return (fraction * spacingPx.toFloat()).roundToInt()
    }

    private fun calculateRightOffset(column: Int): Int {
        val fraction = (column + 1).toFloat() / spanCount.toFloat()
        return (fraction * spacingPx.toFloat()).roundToInt()
    }
}
