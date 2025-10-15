package dev.tutushkin.allmovies.data.movies

import android.content.Context
import android.net.ConnectivityManager
import androidx.test.core.app.ApplicationProvider
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ImageSizeSelectorTest {

    private lateinit var connectivityManager: ConnectivityManager

    private val configuration = Configuration(
        imagesBaseUrl = "https://image.tmdb.org/t/p/",
        posterSizes = listOf("w154", "w342", "w500", "w780", "original")
    )

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    }

    @Test
    fun `fast network on wide device selects closest large size`() {
        val selector = createSelector(deviceWidth = 900, bandwidth = 10_000)

        val spec = selector.posterSpec()

        assertEquals("w780", spec.sizeKey)
        assertEquals(ImageSizeSelector.GlideStrategy.OVERRIDE, spec.strategy)
        assertEquals(780, spec.targetWidth)
        val url = selector.buildPosterUrl("/poster.jpg")
        assertTrue(url.contains("/w780"))
    }

    @Test
    fun `slow network favors smaller size and thumbnail`() {
        val selector = createSelector(deviceWidth = 900, bandwidth = 100)

        val spec = selector.posterSpec()

        assertEquals("w780", spec.sizeKey)
        assertEquals(ImageSizeSelector.GlideStrategy.THUMBNAIL, spec.strategy)
        assertEquals(0.5f, spec.thumbnailMultiplier ?: 0f, 0.0f)
    }

    @Test
    fun `fast network on narrow device keeps medium size`() {
        val selector = createSelector(deviceWidth = 320, bandwidth = 8_000)

        val spec = selector.posterSpec()

        assertEquals("w342", spec.sizeKey)
        assertEquals(ImageSizeSelector.GlideStrategy.OVERRIDE, spec.strategy)
        assertEquals(342, spec.targetWidth)
    }

    @Test
    fun `slow network on narrow device drops to smallest size`() {
        val selector = createSelector(deviceWidth = 320, bandwidth = 200)

        val spec = selector.posterSpec()

        assertEquals("w154", spec.sizeKey)
        assertEquals(ImageSizeSelector.GlideStrategy.THUMBNAIL, spec.strategy)
        assertEquals(0.5f, spec.thumbnailMultiplier ?: 0f, 0.0f)
    }

    private fun createSelector(deviceWidth: Int, bandwidth: Int): ImageSizeSelector {
        return ImageSizeSelector(
            connectivityManager = connectivityManager,
            configurationProvider = { configuration },
            deviceWidthProvider = { deviceWidth },
            bandwidthProvider = { bandwidth }
        )
    }
}
