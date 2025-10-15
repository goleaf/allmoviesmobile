package dev.tutushkin.allmovies.presentation.navigation

import android.content.Intent
import android.net.Uri

/**
 * Parses deep links intended for navigating to movie details.
 */
class MovieDeepLinkParser {

    data class Result(
        val movieId: Int,
        val slug: String?
    )

    fun parse(intent: Intent?): Result? {
        return parse(intent?.data)
    }

    fun parse(uri: Uri?): Result? {
        val data = uri ?: return null
        if (data.scheme != "app" || data.host != "collection") return null

        val segments = data.pathSegments
        if (segments.size < 2 || segments.firstOrNull() != "movie") return null

        val movieId = segments.getOrNull(1)?.toIntOrNull() ?: return null
        val slug = segments.drop(2).takeIf { it.isNotEmpty() }?.joinToString("/")

        return Result(movieId, slug)
    }
}
