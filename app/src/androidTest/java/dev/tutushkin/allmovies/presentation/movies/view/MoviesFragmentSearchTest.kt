package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.fragment.app.testing.launchFragmentInContainer
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.action.ViewActions.typeText
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.hasDescendant
import androidx.test.espresso.matcher.ViewMatchers.withContentDescription
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.runners.AndroidJUnit4
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
@OptIn(ExperimentalCoroutinesApi::class)
class MoviesFragmentSearchTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val dispatcher = StandardTestDispatcher()
    private lateinit var repository: SearchFakeMoviesRepository

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        repository = SearchFakeMoviesRepository()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun searchDisplaysRemoteResults() {
        repository.nowPlaying = listOf(
            MovieList(id = 1, title = "Intro", isFavorite = false)
        )
        repository.searchResults["Star"] = Result.success(
            listOf(
                MovieList(id = 10, title = "Star Journey", isFavorite = false),
                MovieList(id = 11, title = "Star Knights", isFavorite = false)
            )
        )

        val context = ApplicationProvider.getApplicationContext<Context>()
        val languagePreferences = LanguagePreferences(context)
        languagePreferences.setSelectedLanguage("en")
        val viewModel = MoviesViewModel(repository, languagePreferences)
        val factory = FakeMoviesViewModelFactory(viewModel)

        launchFragmentInContainer<MoviesFragment>(themeResId = R.style.Theme_AppCompat) {
            MoviesFragment().apply {
                viewModelFactoryOverride = factory
            }
        }

        dispatcher.scheduler.advanceUntilIdle()

        onView(withContentDescription(R.string.menu_search_content_description)).perform(click())
        onView(withId(androidx.appcompat.R.id.search_src_text)).perform(typeText("Star"))

        dispatcher.scheduler.advanceTimeBy(MoviesViewModel.SEARCH_DEBOUNCE_MILLIS)
        dispatcher.scheduler.advanceUntilIdle()

        onView(withId(R.id.movies_list_recycler))
            .check(matches(hasDescendant(withText("Star Journey"))))
        onView(withId(R.id.movies_list_recycler))
            .check(matches(hasDescendant(withText("Star Knights"))))
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

    private class SearchFakeMoviesRepository : MoviesRepository {
        var nowPlaying: List<MovieList> = emptyList()
        val searchResults: MutableMap<String, Result<List<MovieList>>> = mutableMapOf()

        override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
            return Result.success(nowPlaying)
        }

        override suspend fun searchMovies(
            apiKey: String,
            language: String,
            query: String,
            includeAdult: Boolean
        ): Result<List<MovieList>> {
            return searchResults[query] ?: Result.success(emptyList())
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
            nowPlaying = nowPlaying.map { movie ->
                if (movie.id == movieId) movie.copy(isFavorite = isFavorite) else movie
            }
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
