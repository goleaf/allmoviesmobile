package dev.tutushkin.allmovies.presentation

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.os.bundleOf
import androidx.navigation.findNavController
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SHARED
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SLUG
import dev.tutushkin.allmovies.presentation.navigation.MovieDeepLinkParser
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
            handleDeepLink(intent)
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (intent == null) return
        setIntent(intent)
        handleDeepLink(intent)
    }

    private val movieDeepLinkParser = MovieDeepLinkParser()

    private fun handleDeepLink(intent: Intent?): Boolean {
        val navController = findNavController(R.id.main_nav_host)
        val result = movieDeepLinkParser.parse(intent)
            ?: return navController.handleDeepLink(intent)

        val args = bundleOf(
            ARG_MOVIE_ID to result.movieId,
            ARG_MOVIE_SLUG to result.slug,
            ARG_MOVIE_SHARED to true
        )

        val deepLinkIntent = Intent(intent).apply {
            putExtras(args)
        }

        return navController.handleDeepLink(deepLinkIntent)
    }
}