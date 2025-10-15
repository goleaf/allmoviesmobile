package dev.tutushkin.allmovies.presentation.analytics

import android.util.Log

interface SharedLinkAnalytics {
    fun logSharedLinkOpened(movieId: Int, slug: String?)
}

object SharedLinkAnalyticsLogger : SharedLinkAnalytics {

    private const val TAG = "SharedLinkAnalytics"

    override fun logSharedLinkOpened(movieId: Int, slug: String?) {
        Log.i(TAG, "Shared link opened: id=$movieId slug=${slug.orEmpty()}")
    }
}
