package dev.tutushkin.allmovies.presentation.images

import android.content.Context
import android.os.Build
import android.widget.ImageView
import androidx.test.core.app.ApplicationProvider
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.utils.images.ConnectionType
import dev.tutushkin.allmovies.utils.images.ConnectivityMonitor
import dev.tutushkin.allmovies.utils.images.ImageSizeSelector
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P])
class GlidePosterImageLoaderTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun `loader applies override and thumbnail when available`() {
        val selector = createSelector(ConnectionType.UNMETERED, 1080)
        val requestManager = RecordingImageRequestManager()
        val loader = GlidePosterImageLoader(requestManager, selector)
        val view = ImageView(context)

        loader.loadPoster(view, "https://image.tmdb.org/t/p/w342/sample.jpg")

        val mainRequest = requestManager.requests.first()
        assertEquals("https://image.tmdb.org/t/p/w500/sample.jpg", mainRequest.url)
        assertEquals(R.drawable.ic_baseline_image_24, mainRequest.placeholders.single())
        assertEquals(R.drawable.ic_baseline_image_24, mainRequest.errors.single())
        assertEquals(500 to 750, mainRequest.overrideSize)

        val thumbnail = mainRequest.thumbnail
        requireNotNull(thumbnail)
        assertEquals("https://image.tmdb.org/t/p/w342/sample.jpg", thumbnail.url)
        assertEquals(view, mainRequest.intoView)
    }

    @Test
    fun `loader clears view when selection empty`() {
        val selector = createSelector(ConnectionType.UNMETERED, 1080)
        val requestManager = RecordingImageRequestManager()
        val loader = GlidePosterImageLoader(requestManager, selector)
        val view = ImageView(context)

        loader.loadPoster(view, "")

        assertEquals(1, requestManager.clearCount)
        val resourceId = Shadows.shadowOf(view.drawable).createdFromResId
        assertEquals(R.drawable.ic_baseline_image_24, resourceId)
        assertEquals(0, requestManager.requests.size)
    }

    @Test
    fun `clear delegates to request manager`() {
        val selector = createSelector(ConnectionType.UNMETERED, 1080)
        val requestManager = RecordingImageRequestManager()
        val loader = GlidePosterImageLoader(requestManager, selector)
        val view = ImageView(context)

        loader.clear(view)

        assertEquals(1, requestManager.clearCount)
    }

    private fun createSelector(connectionType: ConnectionType, deviceWidth: Int): ImageSizeSelector {
        val configuration = Configuration(
            imagesBaseUrl = "https://image.tmdb.org/t/p/",
            posterSizes = listOf("w92", "w154", "w185", "w342", "w500", "w780", "original")
        )
        val monitor = object : ConnectivityMonitor {
            override fun currentConnection(): ConnectionType = connectionType
        }
        return ImageSizeSelector(
            configurationProvider = { configuration },
            deviceWidthProvider = { deviceWidth },
            connectivityMonitor = monitor,
        )
    }

    private class RecordingImageRequestManager : ImageRequestManager {
        val requests = mutableListOf<RecordingImageRequestBuilder>()
        var clearCount: Int = 0

        override fun load(url: String?): ImageRequestBuilder {
            val request = RecordingImageRequestBuilder(url)
            requests += request
            return request
        }

        override fun clear(target: ImageView) {
            clearCount += 1
        }
    }

    private class RecordingImageRequestBuilder(val url: String?) : ImageRequestBuilder {
        val placeholders = mutableListOf<Int>()
        val errors = mutableListOf<Int>()
        var overrideSize: Pair<Int, Int>? = null
        var thumbnail: RecordingImageRequestBuilder? = null
        var intoView: ImageView? = null

        override fun placeholder(resId: Int): ImageRequestBuilder {
            placeholders += resId
            return this
        }

        override fun error(resId: Int): ImageRequestBuilder {
            errors += resId
            return this
        }

        override fun override(width: Int, height: Int): ImageRequestBuilder {
            overrideSize = width to height
            return this
        }

        override fun thumbnail(thumbnailRequest: ImageRequestBuilder): ImageRequestBuilder {
            thumbnail = thumbnailRequest as RecordingImageRequestBuilder
            return this
        }

        override fun into(target: ImageView) {
            intoView = target
        }
    }
}
