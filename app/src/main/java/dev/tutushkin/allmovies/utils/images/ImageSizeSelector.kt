package dev.tutushkin.allmovies.utils.images

import dev.tutushkin.allmovies.domain.movies.models.Configuration
import kotlin.math.max

class ImageSizeSelector(
    private val configurationProvider: () -> Configuration,
    private val deviceWidthProvider: () -> Int,
    private val connectivityMonitor: ConnectivityMonitor,
) {

    fun selectPoster(posterUrl: String): ImageSelection {
        if (posterUrl.isBlank()) {
            return ImageSelection(primaryUrl = null, thumbnailUrl = null, overrideWidthPx = null)
        }

        val configuration = configurationProvider()
        val baseUrl = configuration.imagesBaseUrl
        val parsed = parsePosterPath(baseUrl, posterUrl)
            ?: return ImageSelection(primaryUrl = posterUrl, thumbnailUrl = null, overrideWidthPx = null)

        val (initialSize, posterPath) = parsed
        val availableSizes = configuration.posterSizes.takeIf { it.isNotEmpty() }
            ?: listOf(initialSize)

        val orderedSizes = availableSizes
            .map { PosterSize(it) }
            .sortedBy { it.order }

        if (orderedSizes.isEmpty()) {
            return ImageSelection(primaryUrl = posterUrl, thumbnailUrl = null, overrideWidthPx = null)
        }

        val connection = connectivityMonitor.currentConnection()
        val deviceWidthPx = max(0, deviceWidthProvider())

        val desiredWidth = determineDesiredWidth(deviceWidthPx)
        val desiredIndex = orderedSizes.indexOfFirst { it.order >= desiredWidth }
            .takeIf { it >= 0 }
            ?: orderedSizes.lastIndex

        val adjustment = when (connection) {
            ConnectionType.UNMETERED -> 0
            ConnectionType.METERED -> -1
            ConnectionType.OFFLINE -> -2
        }

        val primaryIndex = (desiredIndex + adjustment).coerceIn(0, orderedSizes.lastIndex)
        val primary = orderedSizes[primaryIndex]
        val thumbnail = orderedSizes.getOrNull((primaryIndex - 1).coerceAtLeast(0))
            ?.takeIf { it != primary }

        val primaryUrl = buildPosterUrl(baseUrl, primary.size, posterPath)
        val thumbnailUrl = thumbnail?.let { buildPosterUrl(baseUrl, it.size, posterPath) }
        val overrideWidth = primary.width

        return ImageSelection(
            primaryUrl = primaryUrl,
            thumbnailUrl = thumbnailUrl,
            overrideWidthPx = overrideWidth,
        )
    }

    private fun parsePosterPath(baseUrl: String, posterUrl: String): Pair<String, String>? {
        if (!posterUrl.startsWith(baseUrl)) {
            return null
        }
        val suffix = posterUrl.removePrefix(baseUrl)
        val slashIndex = suffix.indexOf('/')
        if (slashIndex <= 0 || slashIndex >= suffix.length) {
            return null
        }
        val size = suffix.substring(0, slashIndex)
        val path = suffix.substring(slashIndex)
        return size to path
    }

    private fun determineDesiredWidth(deviceWidthPx: Int): Int = when {
        deviceWidthPx >= 1600 -> 780
        deviceWidthPx >= 1080 -> 500
        deviceWidthPx >= 720 -> 342
        deviceWidthPx >= 480 -> 185
        deviceWidthPx >= 320 -> 154
        else -> 92
    }

    private fun buildPosterUrl(baseUrl: String, size: String, path: String): String {
        return buildString(baseUrl.length + size.length + path.length) {
            append(baseUrl)
            append(size)
            append(path)
        }
    }

    data class ImageSelection(
        val primaryUrl: String?,
        val thumbnailUrl: String?,
        val overrideWidthPx: Int?,
    )

    private data class PosterSize(val size: String) {
        val width: Int? = size.removePrefix("w").toIntOrNull()
        val order: Int = width ?: Int.MAX_VALUE
    }
}
