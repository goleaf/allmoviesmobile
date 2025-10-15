package dev.tutushkin.allmovies.presentation

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.os.bundleOf
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SHARED
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SLUG
import dev.tutushkin.allmovies.presentation.movies.view.MoviesFragment
import kotlinx.serialization.ExperimentalSerializationApi

// TODO Add loader
// TODO Add language selection
// TODO Add save favorites
// TODO Add movie search
// TODO Add info about actors (new screen)
// TODO Use Navigation
// TODO Use DI
// TODO Add column alignment to the RecyclerView
// TODO Optimize image sizes dynamically based on a display/network speed/settings
// TODO Add tests
// TODO Add logging
// TODO Replace Toasts with SnackBars

@ExperimentalSerializationApi
class MainActivity : AppCompatActivity() {

    private val deepLinkParser = MovieDeepLinkParser()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        NewNode.init()
        setContentView(R.layout.activity_main)

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .add(R.id.main_container, MoviesFragment())
                .commit()

            handleDeepLink(intent)
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (intent == null) return
        setIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?): Boolean {
        val deepLink = deepLinkParser.parse(intent?.data) ?: return false

        val args = bundleOf(
            ARG_MOVIE_ID to deepLink.movieId,
            ARG_MOVIE_SLUG to deepLink.slug,
            ARG_MOVIE_SHARED to true
        )

        val fragment = MovieDetailsFragment().apply {
            arguments = args
        }

        supportFragmentManager.beginTransaction()
            .addToBackStack(null)
            .replace(R.id.main_container, fragment)
            .commit()

        return true
    }
}