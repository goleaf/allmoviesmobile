package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.os.Build
import android.os.Looper
import android.view.View
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.TestLanguagePreferences
import dev.tutushkin.allmovies.presentation.favorites.TestFavoritesUpdateNotifier
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
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
import androidx.test.core.app.ApplicationProvider
import androidx.work.testing.WorkManagerTestInitHelper
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
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
class MoviesFragmentTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val testDispatcher = StandardTestDispatcher()
    private lateinit var repository: FakeMoviesRepository
    private lateinit var favoritesNotifier: TestFavoritesUpdateNotifier

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        repository = FakeMoviesRepository()
        favoritesNotifier = TestFavoritesUpdateNotifier()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun loadingVisibilityReflectsViewModelState() = runTest(testDispatcher) {
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        WorkManagerTestInitHelper.initializeTestWorkManager(appContext)
        val languagePreferences = TestLanguagePreferences()
        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier)
        val factory = FakeMoviesViewModelFactory(viewModel)

        launchFragment(
            MoviesFragment().apply {
                viewModelFactoryOverride = factory
            }
        ).use { host ->
            testDispatcher.scheduler.runCurrent()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val loadingView = fragment.requireView().findViewById<View>(R.id.movies_list_loading_container)
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.movies_list_recycler)
                assertEquals(View.VISIBLE, loadingView.visibility)
                assertFalse(recycler.isEnabled)
            }

            repository.emitNowPlaying(Result.success(emptyList()))
            testDispatcher.scheduler.runCurrent()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val loadingView = fragment.requireView().findViewById<View>(R.id.movies_list_loading_container)
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.movies_list_recycler)
                assertEquals(View.GONE, loadingView.visibility)
                assertTrue(recycler.isEnabled)
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

    private class FakeMoviesRepository : MoviesRepository {
        private var nowPlayingDeferred = CompletableDeferred<Result<List<MovieList>>>()

        override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
            val result = nowPlayingDeferred.await()
            nowPlayingDeferred = CompletableDeferred()
            return result
        }

        fun emitNowPlaying(result: Result<List<MovieList>>) {
            if (!nowPlayingDeferred.isCompleted) {
                nowPlayingDeferred.complete(result)
            }
        }

        override suspend fun searchMovies(
            apiKey: String,
            language: String,
            query: String,
            includeAdult: Boolean
        ): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun getMovieDetails(
            movieId: Int,
            apiKey: String,
            language: String,
            ensureCached: Boolean
        ): Result<MovieDetails> {
            return Result.failure(UnsupportedOperationException())
        }

        override suspend fun getActorDetails(
            actorId: Int,
            apiKey: String,
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
            // No-op for tests
        }

        override suspend fun refreshLibrary(
            apiKey: String,
            language: String,
            onProgress: (current: Int, total: Int, title: String) -> Unit
        ): Result<Unit> {
            return Result.success(Unit)
        }
    }
}
