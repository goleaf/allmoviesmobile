package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.os.Build
import android.view.ContextThemeWrapper
import android.view.LayoutInflater
import android.widget.FrameLayout
import androidx.test.core.app.ApplicationProvider
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.movies.createImageSizeSelector
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.Certification
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P])
class MovieViewHolderTest {

    @Test
    fun `bind updates favorite icon and propagates clicks`() {
        val baseContext = ApplicationProvider.getApplicationContext<Context>()
        val themedContext = ContextThemeWrapper(baseContext, R.style.Theme_AllMovies)
        val parent = FrameLayout(themedContext)
        val binding = ViewHolderMovieBinding.inflate(LayoutInflater.from(themedContext), parent, false)
        val imageSizeSelector = baseContext.createImageSizeSelector()
        val viewHolder = MovieViewHolder(binding, imageSizeSelector)

        var toggleRequest: Pair<Int, Boolean>? = null
        val listener = object : MoviesClickListener {
            override fun onItemClick(movieId: Int) = Unit

            override fun onToggleFavorite(movieId: Int, isFavorite: Boolean) {
                toggleRequest = movieId to isFavorite
            }
        }

        val movie = MovieList(
            id = 1,
            title = "Movie",
            poster = "",
            ratings = 7.0f,
            numberOfRatings = 10,
            certification = Certification(code = "GENERAL", label = "13+"),
            year = "2023",
            genres = "Action",
            isFavorite = true
        )

        viewHolder.bind(movie, listener)

        assertEquals(android.view.View.VISIBLE, binding.viewHolderMovieLikeImage.visibility)
        val drawable = binding.viewHolderMovieLikeImage.drawable
        assertNotNull(drawable)
        val resId = Shadows.shadowOf(drawable).createdFromResId
        assertEquals(R.drawable.ic_like, resId)

        binding.viewHolderMovieLikeImage.performClick()

        assertEquals(1 to false, toggleRequest)
    }
}
