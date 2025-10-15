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

/**
 * Hosts the top-level fragments. Features such as loaders, search, favorites,
 * language selection, and actor details are implemented in [MoviesFragment]
 * and [MovieDetailsFragment].
 */

@ExperimentalSerializationApi
class MainActivity : AppCompatActivity() {

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
        val data = intent?.data ?: return false
        if (data.scheme != "app" || data.host != "collection") return false

        val segments = data.pathSegments
        if (segments.size < 2 || segments.first() != "movie") return false

        val movieId = segments.getOrNull(1)?.toIntOrNull() ?: return false
        val slug = segments.drop(2).takeIf { it.isNotEmpty() }?.joinToString("/")

        val args = bundleOf(
            ARG_MOVIE_ID to movieId,
            ARG_MOVIE_SLUG to slug,
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