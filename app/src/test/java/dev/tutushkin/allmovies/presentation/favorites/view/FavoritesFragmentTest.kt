package dev.tutushkin.allmovies.presentation.favorites.view

import android.os.Build
import android.os.Looper
import android.view.View
import android.widget.ImageView
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
import dev.tutushkin.allmovies.presentation.TestLogger
import dev.tutushkin.allmovies.presentation.favorites.TestFavoritesUpdateNotifier
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.util.launchFragment
import dev.tutushkin.allmovies.presentation.util.withFragment
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
class FavoritesFragmentTest {

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
    fun displaysSavedFavorites() = runTest(dispatcher) {
        val languagePreferences = TestLanguagePreferences()
        val movie = MovieList(id = 1, title = "Movie", isFavorite = true)
        repository.seedMovies(listOf(movie))
        repository.seedFavorites(listOf(movie))

        val moviesViewModel = MoviesViewModel(
            repository,
            languagePreferences,
            favoritesNotifier,
            TestLogger()
        )
        val favoritesViewModel = FavoritesViewModel(repository, favoritesNotifier)
        val moviesFactory = FakeMoviesViewModelFactory(moviesViewModel)
        val favoritesFactory = FakeFavoritesViewModelFactory(favoritesViewModel)

        launchFragment(
            FavoritesFragment().apply {
                moviesViewModelFactoryOverride = moviesFactory
                favoritesViewModelFactoryOverride = favoritesFactory
            }
        ).use { host ->
            dispatcher.scheduler.advanceUntilIdle()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.favorites_list_recycler)
                val emptyView = fragment.requireView().findViewById<View>(R.id.favorites_list_empty)
                assertEquals(1, recycler.adapter?.itemCount)
                assertEquals(View.GONE, emptyView.visibility)
            }
        }
    }

    @Test
    fun removingFavoriteUpdatesList() = runTest(dispatcher) {
        val languagePreferences = TestLanguagePreferences()
        val movie = MovieList(id = 7, title = "Favorite", isFavorite = true)
        repository.seedMovies(listOf(movie))
        repository.seedFavorites(listOf(movie))

        val moviesViewModel = MoviesViewModel(
            repository,
            languagePreferences,
            favoritesNotifier,
            TestLogger()
        )
        val favoritesViewModel = FavoritesViewModel(repository, favoritesNotifier)
        val moviesFactory = FakeMoviesViewModelFactory(moviesViewModel)
        val favoritesFactory = FakeFavoritesViewModelFactory(favoritesViewModel)

        launchFragment(
            FavoritesFragment().apply {
                moviesViewModelFactoryOverride = moviesFactory
                favoritesViewModelFactoryOverride = favoritesFactory
            }
        ).use { host ->
            dispatcher.scheduler.advanceUntilIdle()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.favorites_list_recycler)
                recycler.measure(0, 0)
                recycler.layout(0, 0, 1000, 1000)
                val holder = recycler.findViewHolderForAdapterPosition(0)
                require(holder != null)
                val toggle = holder.itemView.findViewById<ImageView>(R.id.view_holder_movie_like_image)
                toggle.performClick()
            }

            dispatcher.scheduler.advanceUntilIdle()
            shadowOf(Looper.getMainLooper()).idle()

            host.withFragment { fragment ->
                val recycler = fragment.requireView().findViewById<RecyclerView>(R.id.favorites_list_recycler)
                val emptyView = fragment.requireView().findViewById<View>(R.id.favorites_list_empty)
                assertEquals(0, recycler.adapter?.itemCount)
                assertEquals(View.VISIBLE, emptyView.visibility)
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

    private class FakeFavoritesViewModelFactory(
        private val viewModel: FavoritesViewModel
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(FavoritesViewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return viewModel as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }

    private class FakeMoviesRepository : MoviesRepository {
        private val storedMovies = mutableMapOf<Int, MovieList>()
        private val nowPlaying = mutableListOf<MovieList>()
        private val favorites = mutableListOf<MovieList>()

        fun seedMovies(movies: List<MovieList>) {
            nowPlaying.clear()
            nowPlaying.addAll(movies)
            movies.forEach { storedMovies[it.id] = it }
        }

        fun seedFavorites(items: List<MovieList>) {
            favorites.clear()
            favorites.addAll(items)
            items.forEach { storedMovies[it.id] = it }
        }

        override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
            return Result.success(nowPlaying.toList())
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
            return Result.success(Unit).also {
                val updatedNowPlaying = nowPlaying.map { movie ->
                    if (movie.id == movieId) movie.copy(isFavorite = isFavorite) else movie
                }
                nowPlaying.clear()
                nowPlaying.addAll(updatedNowPlaying)

                val existing = storedMovies[movieId] ?: MovieList(id = movieId, title = "Movie $movieId")
                storedMovies[movieId] = existing.copy(isFavorite = isFavorite)

                if (isFavorite) {
                    val favoriteMovie = storedMovies[movieId]!!.copy(isFavorite = true)
                    val index = favorites.indexOfFirst { it.id == movieId }
                    if (index >= 0) {
                        favorites[index] = favoriteMovie
                    } else {
                        favorites.add(favoriteMovie)
                    }
                } else {
                    favorites.removeAll { it.id == movieId }
                }
            }
        }

        override suspend fun getFavorites(): Result<List<MovieList>> {
            return Result.success(favorites.map { if (it.isFavorite) it else it.copy(isFavorite = true) })
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
