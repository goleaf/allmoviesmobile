package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.os.Looper
import android.view.View
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ApplicationProvider
import androidx.work.testing.WorkManagerTestInitHelper
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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlinx.serialization.ExperimentalSerializationApi
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
class MoviesGridDecorationTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val testDispatcher = StandardTestDispatcher()
    private lateinit var favoritesNotifier: TestFavoritesUpdateNotifier
    private lateinit var originalCalculator: ResponsiveGridCalculator

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        favoritesNotifier = TestFavoritesUpdateNotifier()
        originalCalculator = ResponsiveGridCalculatorProvider.calculator
        ResponsiveGridCalculatorProvider.calculator = ResponsiveGridCalculatorImpl()
        val context = ApplicationProvider.getApplicationContext<Context>()
        WorkManagerTestInitHelper.initializeTestWorkManager(context)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
        ResponsiveGridCalculatorProvider.calculator = originalCalculator
    }

    @Test
    fun spacingDecorationKeepsEdgePadding() = runTest(testDispatcher) {
        val repository = StaticMoviesRepository()
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
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.movies_list_recycler)
                val layoutManager = recycler.layoutManager as GridLayoutManager
                val adapter = recycler.adapter as MoviesAdapter
                val spanCount = layoutManager.spanCount
                val movies = List(spanCount) { index ->
                    MovieList(id = index, title = "Movie $index")
                }
                adapter.submitList(movies)

                testDispatcher.scheduler.runCurrent()
                shadowOf(Looper.getMainLooper()).idle()

                val displayMetrics = fragment.requireContext().resources.displayMetrics
                val widthSpec = View.MeasureSpec.makeMeasureSpec(displayMetrics.widthPixels, View.MeasureSpec.EXACTLY)
                val heightSpec = View.MeasureSpec.makeMeasureSpec(displayMetrics.heightPixels, View.MeasureSpec.AT_MOST)
                recycler.measure(widthSpec, heightSpec)
                recycler.layout(0, 0, recycler.measuredWidth, recycler.measuredHeight)

                val decoration = recycler.getItemDecorationAt(0) as SpacingItemDecoration
                val firstChild = recycler.getChildAt(0)
                val lastChild = recycler.getChildAt(spanCount - 1)
                val firstRect = Rect()
                val lastRect = Rect()
                decoration.getItemOffsets(firstRect, firstChild, recycler, RecyclerView.State())
                decoration.getItemOffsets(lastRect, lastChild, recycler, RecyclerView.State())

                val expectedSpacing = fragment.resources.getDimensionPixelSize(R.dimen.movies_grid_spacing)
                assertEquals(expectedSpacing, firstRect.left)
                assertEquals(expectedSpacing, lastRect.right)
            }
        }
    }

    private class FakeMoviesViewModelFactory(
        private val viewModel: MoviesViewModel,
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MoviesViewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return viewModel as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }

    private class StaticMoviesRepository : MoviesRepository {
        override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun searchMovies(
            apiKey: String,
            language: String,
            query: String,
            includeAdult: Boolean,
        ): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun getMovieDetails(
            movieId: Int,
            apiKey: String,
            language: String,
            ensureCached: Boolean,
        ): Result<MovieDetails> {
            return Result.failure(UnsupportedOperationException())
        }

        override suspend fun getActorDetails(
            actorId: Int,
            apiKey: String,
            language: String,
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
            onProgress: (current: Int, total: Int, title: String) -> Unit,
        ): Result<Unit> {
            return Result.success(Unit)
        }
    }
}
