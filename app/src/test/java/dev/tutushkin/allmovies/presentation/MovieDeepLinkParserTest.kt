package dev.tutushkin.allmovies.presentation

import android.net.Uri
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class MovieDeepLinkParserTest {

    private val parser = MovieDeepLinkParser()

    @Test
    fun `parse returns deep link for valid movie link with slug`() {
        val uri = Uri.parse("app://collection/movie/42/inception")

        val result = parser.parse(uri)

        assertNotNull(result)
        assertEquals(42, result!!.movieId)
        assertEquals("inception", result.slug)
    }

    @Test
    fun `parse returns deep link for valid movie link without slug`() {
        val uri = Uri.parse("app://collection/movie/42")

        val result = parser.parse(uri)

        assertNotNull(result)
        assertEquals(42, result!!.movieId)
        assertNull(result.slug)
    }

    @Test
    fun `parse returns null for malformed scheme`() {
        val uri = Uri.parse("https://collection/movie/42")

        val result = parser.parse(uri)

        assertNull(result)
    }

    @Test
    fun `parse returns null for short path segments`() {
        val uri = Uri.parse("app://collection/movie")

        val result = parser.parse(uri)

        assertNull(result)
    }
}
