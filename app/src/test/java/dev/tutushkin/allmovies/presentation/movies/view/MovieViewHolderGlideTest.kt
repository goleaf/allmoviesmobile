package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.net.ConnectivityManager
import android.view.LayoutInflater
import android.widget.FrameLayout
import androidx.test.core.app.ApplicationProvider
import com.bumptech.glide.request.target.Target
import dev.tutushkin.allmovies.data.movies.ImageSizeSelector
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MovieViewHolderGlideTest {

    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var parent: FrameLayout
    private lateinit var layoutInflater: LayoutInflater

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        parent = FrameLayout(context)
        layoutInflater = LayoutInflater.from(context)
    }

    @Test
    fun `bind loads url with override on fast network`() {
        val selector = createSelector(deviceWidth = 900, bandwidth = 8_000)
        val posterUrl = selector.buildPosterUrl("/poster.jpg")
        val binding = ViewHolderMovieBinding.inflate(layoutInflater, parent, false)
        val fakeManager = FakePosterRequestManager()
        val holder = MovieViewHolder(binding, selector) { fakeManager }
        val movie = MovieList(
            id = 1,
            title = "Movie",
            poster = posterUrl,
            ratings = 8.0f,
            numberOfRatings = 10,
            minimumAge = "13+",
            year = "2023",
            genres = "Action",
            isFavorite = false
        )

        holder.bind(movie, fakeClickListener)

        assertTrue(fakeManager.lastUrl?.contains("/w780") == true)
        assertEquals(780, fakeManager.overrideWidth)
        assertEquals(TargetSizeOriginal, fakeManager.overrideHeight)
        assertNull(fakeManager.thumbnailMultiplier)
    }

    @Test
    fun `bind uses thumbnail on slow network`() {
        val selector = createSelector(deviceWidth = 320, bandwidth = 200)
        val posterUrl = selector.buildPosterUrl("/poster.jpg")
        val binding = ViewHolderMovieBinding.inflate(layoutInflater, parent, false)
        val fakeManager = FakePosterRequestManager()
        val holder = MovieViewHolder(binding, selector) { fakeManager }
        val movie = MovieList(
            id = 2,
            title = "Movie",
            poster = posterUrl,
            ratings = 7.0f,
            numberOfRatings = 5,
            minimumAge = "13+",
            year = "2022",
            genres = "Drama",
            isFavorite = true
        )

        holder.bind(movie, fakeClickListener)

        assertTrue(fakeManager.lastUrl?.contains("/w154") == true)
        assertEquals(0.5f, fakeManager.thumbnailMultiplier ?: 0f, 0.0f)
    }

    private fun createSelector(deviceWidth: Int, bandwidth: Int): ImageSizeSelector {
        val configuration = Configuration(
            imagesBaseUrl = "https://image.tmdb.org/t/p/",
            posterSizes = listOf("w154", "w342", "w500", "w780")
        )
        return ImageSizeSelector(
            connectivityManager = connectivityManager,
            configurationProvider = { configuration },
            deviceWidthProvider = { deviceWidth },
            bandwidthProvider = { bandwidth }
        )
    }

    private val fakeClickListener = object : MoviesClickListener {
        override fun onItemClick(movieId: Int) = Unit
        override fun onToggleFavorite(movieId: Int, isFavorite: Boolean) = Unit
    }
}

private const val TargetSizeOriginal = Target.SIZE_ORIGINAL

private class FakePosterRequestManager : PosterRequestManager {
    var lastUrl: String? = null
    var overrideWidth: Int? = null
    var overrideHeight: Int? = null
    var thumbnailMultiplier: Float? = null

    override fun load(url: String): PosterRequestBuilder {
        lastUrl = url
        return Builder(this)
    }

    private class Builder(private val manager: FakePosterRequestManager) : PosterRequestBuilder {
        override fun placeholder(drawableRes: Int): PosterRequestBuilder = this

        override fun error(drawableRes: Int): PosterRequestBuilder = this

        override fun override(width: Int, height: Int): PosterRequestBuilder {
            manager.overrideWidth = width
            manager.overrideHeight = height
            return this
        }

        override fun thumbnail(sizeMultiplier: Float): PosterRequestBuilder {
            manager.thumbnailMultiplier = sizeMultiplier
            return this
        }

        override fun into(imageView: android.widget.ImageView) {
            // no-op
        }
    }
}
