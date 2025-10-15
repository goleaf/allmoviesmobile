package dev.tutushkin.allmovies.presentation

import android.content.Intent
import android.net.Uri
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SHARED
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SLUG
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityDeepLinkTest {

    @Test
    fun launchesMovieDetailsWhenDeepLinkReceived() {
        val deepLink = Uri.parse("app://collection/movie/99/the-movie")
        val intent = Intent(Intent.ACTION_VIEW, deepLink)

        ActivityScenario.launch<MainActivity>(intent).use { scenario ->
            scenario.onActivity { activity ->
                val fragment = activity.supportFragmentManager.findFragmentById(R.id.main_container)
                assertTrue(fragment is MovieDetailsFragment)

                val arguments = fragment?.arguments
                val movieId = arguments?.getInt(ARG_MOVIE_ID)
                val slug = arguments?.getString(ARG_MOVIE_SLUG)
                val isShared = arguments?.getBoolean(ARG_MOVIE_SHARED)

                assertEquals(99, movieId)
                assertEquals("the-movie", slug)
                assertTrue(isShared == true)
            }
        }
    }
}
