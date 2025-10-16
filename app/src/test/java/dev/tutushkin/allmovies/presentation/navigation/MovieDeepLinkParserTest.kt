package dev.tutushkin.allmovies.presentation.navigation

import android.content.Intent
import android.net.Uri
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class MovieDeepLinkParserTest {

    private val parser = MovieDeepLinkParser()

    @Test
    fun `parse returns result for valid movie deep link without slug`() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("app://collection/movie/42"))

        val result = parser.parse(intent)

        assertNotNull(result)
        assertEquals(42, result?.movieId)
        assertNull(result?.slug)
    }

    @Test
    fun `parse returns result for valid movie deep link with slug`() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("app://collection/movie/42/test/movie"))

        val result = parser.parse(intent)

        assertNotNull(result)
        assertEquals(42, result?.movieId)
        assertEquals("test/movie", result?.slug)
    }

    @Test
    fun `parse returns null for invalid deep link`() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://example.com/movie/42"))

        val result = parser.parse(intent)

        assertNull(result)
    }

    @Test
    fun `parse returns null when movie id is not integer`() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("app://collection/movie/not-a-number"))

        val result = parser.parse(intent)

        assertNull(result)
    }

    @Test
    fun `parse returns null when path segments missing`() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("app://collection/"))

        val result = parser.parse(intent)

        assertNull(result)
    }
}
