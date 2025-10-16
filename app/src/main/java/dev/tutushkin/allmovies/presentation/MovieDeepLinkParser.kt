package dev.tutushkin.allmovies.presentation

import android.net.Uri

data class MovieDeepLink(
    val movieId: Int,
    val slug: String?
)

class MovieDeepLinkParser {

    fun parse(uri: Uri?): MovieDeepLink? {
        if (uri == null) return null
        if (uri.scheme != "app" || uri.host != "collection") return null

        val segments = uri.pathSegments
        if (segments.size < 2) return null
        if (segments.firstOrNull() != "movie") return null

        val movieId = segments.getOrNull(1)?.toIntOrNull() ?: return null
        val slug = segments.drop(2)
            .filter { it.isNotBlank() }
            .takeIf { it.isNotEmpty() }
            ?.joinToString(separator = "/")

        return MovieDeepLink(movieId = movieId, slug = slug)
    }
}
