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

    private fun handleDeepLink(intent: Intent?): Boolean {
        val navController = findNavController(R.id.main_nav_host)
        val data = intent?.data ?: return navController.handleDeepLink(intent)
        if (data.scheme != "app" || data.host != "collection") {
            return navController.handleDeepLink(intent)
        }

        val segments = data.pathSegments
        if (segments.size < 2 || segments.first() != "movie") return false

        val movieId = segments.getOrNull(1)?.toIntOrNull() ?: return false
        val slug = segments.drop(2).takeIf { it.isNotEmpty() }?.joinToString("/")

        val args = bundleOf(
            ARG_MOVIE_ID to movieId,
            ARG_MOVIE_SLUG to slug,
            ARG_MOVIE_SHARED to true
        )

        val deepLinkIntent = Intent(intent).apply {
            putExtras(args)
        }

        return navController.handleDeepLink(deepLinkIntent)
    }
}