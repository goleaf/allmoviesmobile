package dev.tutushkin.allmovies.presentation.moviedetails.view

import android.os.Build
import android.os.Looper
import android.view.View
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.core.os.bundleOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.TestLanguagePreferences
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalytics
import dev.tutushkin.allmovies.presentation.favorites.TestFavoritesUpdateNotifier
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.util.launchFragment
import dev.tutushkin.allmovies.presentation.util.withFragment
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.io.use
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P])
@OptIn(ExperimentalCoroutinesApi::class, ExperimentalSerializationApi::class)
class MovieDetailsFragmentTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val dispatcher = StandardTestDispatcher()
    private lateinit var repository: FakeMoviesRepository
    private lateinit var favoritesNotifier: TestFavoritesUpdateNotifier

    @Before
    fun setup() {
        Dispatchers.setMain(dispatcher)
        repository = FakeMoviesRepository()
        favoritesNotifier = TestFavoritesUpdateNotifier()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun progressOverlayReflectsLoadingState() = runTest(dispatcher) {
        val languagePreferences = TestLanguagePreferences()
        val moviesViewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier)
        val language = languagePreferences.getSelectedLanguage()
        val movieId = 42
        val args = bundleOf(ARG_MOVIE_ID to movieId)
        val detailsFactory = FakeMovieDetailsViewModelFactory(
            repository,
            movieId,
            language,
            moviesViewModel
        )
        val moviesFactory = FakeMoviesViewModelFactory(moviesViewModel)

        launchFragment(
            MovieDetailsFragment().apply {
                arguments = args
                moviesViewModelFactoryOverride = moviesFactory
                viewModelFactoryOverride = detailsFactory
            }
        ).use { host ->
            dispatcher.scheduler.runCurrent()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val overlay = fragment.requireView().findViewById<View>(R.id.movies_details_loading_overlay)
                val share = fragment.requireView().findViewById<View>(R.id.movies_details_share_image)
                val favorite = fragment.requireView().findViewById<View>(R.id.movies_details_favorite_image)
                assertEquals(View.VISIBLE, overlay.visibility)
                assertEquals(View.GONE, share.visibility)
                assertEquals(View.GONE, favorite.visibility)
            }

            val movieDetails = MovieDetails(
                id = movieId,
                title = "Title",
                overview = "Overview",
                poster = "",
                backdrop = "",
                ratings = 8f,
                numberOfRatings = 25,
                minimumAge = "13+",
                runtime = 120,
                genres = "Action"
            )
            repository.emitMovieDetails(Result.success(movieDetails))
            dispatcher.scheduler.runCurrent()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val overlay = fragment.requireView().findViewById<View>(R.id.movies_details_loading_overlay)
                assertEquals(View.GONE, overlay.visibility)
            }
        }
    }

    private class FakeMoviesViewModelFactory(
        private val viewModel: MoviesViewModel
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MoviesViewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return viewModel as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }

    private class FakeMovieDetailsViewModelFactory(
        private val repository: FakeMoviesRepository,
        private val movieId: Int,
        private val language: String,
        private val moviesViewModel: MoviesViewModel
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MovieDetailsViewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return MovieDetailsViewModel(
                    repository,
                    movieId,
                    slug = null,
                    openedFromSharedLink = false,
                    analytics = FakeSharedLinkAnalytics,
                    language = language,
                    moviesViewModel = moviesViewModel
                ) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }

    private class FakeMoviesRepository : MoviesRepository {
        private var movieDetailsDeferred = CompletableDeferred<Result<MovieDetails>>()

        override suspend fun getConfiguration(language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(language: String): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun searchMovies(
            language: String,
            query: String,
            includeAdult: Boolean
        ): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun getMovieDetails(
            movieId: Int,
            language: String,
            ensureCached: Boolean
        ): Result<MovieDetails> {
            val result = movieDetailsDeferred.await()
            movieDetailsDeferred = CompletableDeferred()
            return result
        }

        fun emitMovieDetails(result: Result<MovieDetails>) {
            if (!movieDetailsDeferred.isCompleted) {
                movieDetailsDeferred.complete(result)
            }
        }

        override suspend fun getActorDetails(
            actorId: Int,
            language: String
        ): Result<ActorDetails> {
            return Result.failure(UnsupportedOperationException())
        }

        override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> {
            return Result.success(Unit)
        }

        override suspend fun getFavorites(): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun clearAll() {
            // No-op
        }

        override suspend fun refreshLibrary(
            language: String,
            onProgress: (current: Int, total: Int, title: String) -> Unit
        ): Result<Unit> {
            return Result.success(Unit)
        }
    }

    private object FakeSharedLinkAnalytics : SharedLinkAnalytics {
        override fun logSharedLinkOpened(movieId: Int, slug: String?) {
            // No-op
        }
    }
}
