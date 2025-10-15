package dev.tutushkin.allmovies.data.movies

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import kotlin.math.abs

class ImageSizeSelector(
    private val connectivityManager: ConnectivityManager,
    private val configurationProvider: () -> Configuration = { Configuration() },
    private val deviceWidthProvider: () -> Int,
    private val bandwidthProvider: (ConnectivityManager) -> Int? = ::getBandwidth
) {

    fun posterSpec(): PosterSpec = selectPosterSpec()

    fun buildPosterUrl(posterPath: String?): String {
        if (posterPath.isNullOrBlank()) return ""
        val spec = selectPosterSpec()
        val baseUrl = configurationProvider().imagesBaseUrl
        return "$baseUrl${spec.sizeKey}$posterPath"
    }

    private fun selectPosterSpec(): PosterSpec {
        val configuration = configurationProvider()
        val configuredSizes = configuration.posterSizes.takeIf { it.isNotEmpty() }
            ?: listOf(DEFAULT_POSTER_SIZE)

        val parsedSizes = configuredSizes.map { sizeKey ->
            sizeKey to parsePosterWidth(sizeKey)
        }

        val deviceWidth = deviceWidthProvider().takeIf { it > 0 } ?: DEFAULT_WIDTH
        val isFastNetwork = (bandwidthProvider(connectivityManager) ?: 0) >= FAST_BANDWIDTH_THRESHOLD_KBPS

        val sortedSizes = parsedSizes.sortedBy { it.second }

        val selectedPair = if (isFastNetwork) {
            findClosestSize(sortedSizes, deviceWidth) ?: DEFAULT_SIZE_PAIR
        } else {
            findLargestBelowOrEqual(sortedSizes, deviceWidth)
                ?: sortedSizes.firstOrNull()
                ?: DEFAULT_SIZE_PAIR
        }

        val resolvedWidth = when (selectedPair.second) {
            Int.MAX_VALUE -> deviceWidth
            else -> selectedPair.second
        }

        val strategy = if (isFastNetwork) GlideStrategy.OVERRIDE else GlideStrategy.THUMBNAIL
        val multiplier = if (strategy == GlideStrategy.THUMBNAIL) SLOW_THUMBNAIL_MULTIPLIER else null

        return PosterSpec(
            sizeKey = selectedPair.first,
            targetWidth = resolvedWidth,
            strategy = strategy,
            thumbnailMultiplier = multiplier
        )
    }

    private fun parsePosterWidth(sizeKey: String): Int {
        if (sizeKey.equals(ORIGINAL_KEY, ignoreCase = true)) {
            return Int.MAX_VALUE
        }
        val numericPart = sizeKey.trim().removePrefix("w").removePrefix("W")
        return numericPart.toIntOrNull() ?: DEFAULT_WIDTH
    }

    private fun findClosestSize(
        sizes: List<Pair<String, Int>>,
        target: Int
    ): Pair<String, Int>? {
        if (sizes.isEmpty()) return null
        return sizes.minByOrNull { (_, width) ->
            if (width == Int.MAX_VALUE) Long.MAX_VALUE else abs(width.toLong() - target.toLong())
        }
    }

    private fun findLargestBelowOrEqual(
        sizes: List<Pair<String, Int>>,
        target: Int
    ): Pair<String, Int>? {
        return sizes
            .filter { (_, width) -> width != Int.MAX_VALUE && width <= target }
            .maxByOrNull { it.second }
    }

    data class PosterSpec(
        val sizeKey: String,
        val targetWidth: Int,
        val strategy: GlideStrategy,
        val thumbnailMultiplier: Float?
    )

    enum class GlideStrategy {
        OVERRIDE,
        THUMBNAIL
    }

    companion object {
        private const val DEFAULT_POSTER_SIZE = "w342"
        private const val ORIGINAL_KEY = "original"
        private const val DEFAULT_WIDTH = 342
        private const val FAST_BANDWIDTH_THRESHOLD_KBPS = 1_500
        private const val SLOW_THUMBNAIL_MULTIPLIER = 0.5f
        private val DEFAULT_SIZE_PAIR = DEFAULT_POSTER_SIZE to DEFAULT_WIDTH
        
        private fun getBandwidth(cm: ConnectivityManager): Int? {
            val network = cm.activeNetwork ?: return null
            val capabilities = cm.getNetworkCapabilities(network) ?: return null
            val downstream = capabilities.linkDownstreamBandwidthKbps
            return if (downstream <= 0) null else downstream
        }
    }
}

fun Context.createImageSizeSelector(): ImageSizeSelector {
    val appContext = applicationContext
    val connectivityManager =
        appContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    return ImageSizeSelector(
        connectivityManager = connectivityManager,
        deviceWidthProvider = { appContext.resources.displayMetrics.widthPixels }
    )
}
