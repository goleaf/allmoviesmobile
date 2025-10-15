package dev.tutushkin.allmovies.presentation.images

import android.graphics.drawable.Drawable
import android.view.View
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.bumptech.glide.RequestBuilder
import com.bumptech.glide.RequestManager
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.utils.images.ImageSizeSelector
import kotlin.math.roundToInt

interface PosterImageLoader {
    fun loadPoster(target: ImageView, posterUrl: String)
    fun clear(target: ImageView)
}

fun interface PosterImageLoaderFactory {
    fun create(targetView: View): PosterImageLoader
}

class GlidePosterImageLoader(
    private val requestManager: ImageRequestManager,
    private val imageSizeSelector: ImageSizeSelector,
) : PosterImageLoader {

    override fun loadPoster(target: ImageView, posterUrl: String) {
        val selection = imageSizeSelector.selectPoster(posterUrl)
        val primaryUrl = selection.primaryUrl

        if (primaryUrl.isNullOrBlank()) {
            requestManager.clear(target)
            target.setImageResource(R.drawable.ic_baseline_image_24)
            return
        }

        val mainRequest = requestManager
            .load(primaryUrl)
            .placeholder(R.drawable.ic_baseline_image_24)
            .error(R.drawable.ic_baseline_image_24)

        selection.overrideWidthPx?.let { width ->
            val height = (width * POSTER_ASPECT_RATIO).roundToInt()
            mainRequest.override(width, height)
        }

        val finalRequest = selection.thumbnailUrl?.let { thumbnailUrl ->
            val thumbnailRequest = requestManager.load(thumbnailUrl)
            mainRequest.thumbnail(thumbnailRequest)
        } ?: mainRequest

        finalRequest.into(target)
    }

    override fun clear(target: ImageView) {
        requestManager.clear(target)
    }

    companion object {
        private const val POSTER_ASPECT_RATIO = 3f / 2f
    }
}

class GlidePosterImageLoaderFactory(
    private val imageSizeSelector: ImageSizeSelector,
) : PosterImageLoaderFactory {

    override fun create(targetView: View): PosterImageLoader {
        val requestManager = Glide.with(targetView)
        return GlidePosterImageLoader(RealImageRequestManager(requestManager), imageSizeSelector)
    }
}

internal interface ImageRequestManager {
    fun load(url: String?): ImageRequestBuilder
    fun clear(target: ImageView)
}

internal interface ImageRequestBuilder {
    fun placeholder(resId: Int): ImageRequestBuilder
    fun error(resId: Int): ImageRequestBuilder
    fun override(width: Int, height: Int): ImageRequestBuilder
    fun thumbnail(thumbnailRequest: ImageRequestBuilder): ImageRequestBuilder
    fun into(target: ImageView)
}

private class RealImageRequestManager(
    private val requestManager: RequestManager,
) : ImageRequestManager {

    override fun load(url: String?): ImageRequestBuilder {
        return RealImageRequestBuilder(requestManager.load(url))
    }

    override fun clear(target: ImageView) {
        requestManager.clear(target)
    }
}

private class RealImageRequestBuilder(
    private val requestBuilder: RequestBuilder<Drawable>,
) : ImageRequestBuilder {

    override fun placeholder(resId: Int): ImageRequestBuilder {
        requestBuilder.placeholder(resId)
        return this
    }

    override fun error(resId: Int): ImageRequestBuilder {
        requestBuilder.error(resId)
        return this
    }

    override fun override(width: Int, height: Int): ImageRequestBuilder {
        requestBuilder.override(width, height)
        return this
    }

    override fun thumbnail(thumbnailRequest: ImageRequestBuilder): ImageRequestBuilder {
        val realBuilder = thumbnailRequest as? RealImageRequestBuilder
            ?: throw IllegalArgumentException("Thumbnail request must originate from GlidePosterImageLoader")
        requestBuilder.thumbnail(realBuilder.requestBuilder)
        return this
    }

    override fun into(target: ImageView) {
        requestBuilder.into(target)
    }
}
