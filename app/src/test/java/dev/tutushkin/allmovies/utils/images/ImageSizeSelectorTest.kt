package dev.tutushkin.allmovies.utils.images

import dev.tutushkin.allmovies.domain.movies.models.Configuration
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ImageSizeSelectorTest {

    private val baseUrl = "https://image.tmdb.org/t/p/"
    private val sizes = listOf("w92", "w154", "w185", "w342", "w500", "w780", "original")

    @Test
    fun `unmetered connection selects larger size`() {
        val selector = createSelector(ConnectionType.UNMETERED, deviceWidth = 1080)
        val selection = selector.selectPoster("${baseUrl}w342/sample.jpg")

        assertEquals("${baseUrl}w500/sample.jpg", selection.primaryUrl)
        assertEquals("${baseUrl}w342/sample.jpg", selection.thumbnailUrl)
        assertEquals(500, selection.overrideWidthPx)
    }

    @Test
    fun `metered connection steps down one size`() {
        val selector = createSelector(ConnectionType.METERED, deviceWidth = 1080)
        val selection = selector.selectPoster("${baseUrl}w342/sample.jpg")

        assertEquals("${baseUrl}w342/sample.jpg", selection.primaryUrl)
        assertEquals("${baseUrl}w185/sample.jpg", selection.thumbnailUrl)
        assertEquals(342, selection.overrideWidthPx)
    }

    @Test
    fun `offline connection falls back further`() {
        val selector = createSelector(ConnectionType.OFFLINE, deviceWidth = 1080)
        val selection = selector.selectPoster("${baseUrl}w342/sample.jpg")

        assertEquals("${baseUrl}w185/sample.jpg", selection.primaryUrl)
        assertEquals("${baseUrl}w154/sample.jpg", selection.thumbnailUrl)
        assertEquals(185, selection.overrideWidthPx)
    }

    @Test
    fun `unknown base url returns original url without overrides`() {
        val selector = createSelector(ConnectionType.UNMETERED, deviceWidth = 1080)
        val selection = selector.selectPoster("https://example.com/image.jpg")

        assertEquals("https://example.com/image.jpg", selection.primaryUrl)
        assertNull(selection.thumbnailUrl)
        assertNull(selection.overrideWidthPx)
    }

    @Test
    fun `blank poster returns empty selection`() {
        val selector = createSelector(ConnectionType.UNMETERED, deviceWidth = 1080)
        val selection = selector.selectPoster("")

        assertNull(selection.primaryUrl)
        assertNull(selection.thumbnailUrl)
        assertNull(selection.overrideWidthPx)
    }

    private fun createSelector(connectionType: ConnectionType, deviceWidth: Int): ImageSizeSelector {
        val configuration = Configuration(imagesBaseUrl = baseUrl, posterSizes = sizes)
        val connectivityMonitor = object : ConnectivityMonitor {
            override fun currentConnection(): ConnectionType = connectionType
        }
        return ImageSizeSelector(
            configurationProvider = { configuration },
            deviceWidthProvider = { deviceWidth },
            connectivityMonitor = connectivityMonitor,
        )
    }
}
