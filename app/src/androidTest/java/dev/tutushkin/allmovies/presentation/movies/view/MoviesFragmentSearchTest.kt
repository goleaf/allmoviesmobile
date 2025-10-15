package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.fragment.app.testing.launchFragmentInContainer
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.action.ViewActions.closeSoftKeyboard
import androidx.test.espresso.action.ViewActions.pressImeActionButton
import androidx.test.espresso.action.ViewActions.typeText
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.MediumTest
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModelFactory
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
@MediumTest
class MoviesFragmentSearchTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    @Test
    fun searchViewFiltersMoviesAndRestoresNowPlaying() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val preferences = LanguagePreferences(context).apply { setSelectedLanguage("en") }
        val repository = TestMoviesRepository()
        repository.nowPlayingResult = Result.success(
            listOf(MovieList(id = 1, title = "Now Playing Movie"))
        )
        repository.searchResponses["Matrix"] = Result.success(
            listOf(MovieList(id = 2, title = "Matrix Result"))
        )

        val scenario = launchFragmentInContainer<MoviesFragment>(themeResId = R.style.Theme_AppCompat) {
            MoviesFragment().apply {
                viewModelFactoryOverride = MoviesViewModelFactory(repository, preferences)
            }
        }

        onView(withText("Now Playing Movie")).check(matches(isDisplayed()))

        onView(withId(R.id.action_search)).perform(click())
        onView(withId(androidx.appcompat.R.id.search_src_text))
            .perform(typeText("Matrix"), pressImeActionButton(), closeSoftKeyboard())

        onView(withText("Matrix Result")).check(matches(isDisplayed()))

        onView(withId(androidx.appcompat.R.id.search_close_btn)).perform(click())

        onView(withText("Now Playing Movie")).check(matches(isDisplayed()))

        scenario.close()
    }
}

private class TestMoviesRepository : MoviesRepository {

    var nowPlayingResult: Result<List<MovieList>> = Result.success(emptyList())
    val searchResponses: MutableMap<String, Result<List<MovieList>>> = mutableMapOf()

    override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> =
        Result.success(Configuration())

    override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> =
        Result.success(emptyList())

    override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> =
        nowPlayingResult

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String
    ): Result<List<MovieList>> = searchResponses[query] ?: Result.success(emptyList())

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String,
        ensureCached: Boolean
    ): Result<MovieDetails> = Result.failure(UnsupportedOperationException())

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> = Result.success(Unit)

    override suspend fun getFavorites(): Result<List<MovieList>> = Result.success(emptyList())

    override suspend fun clearAll() {}

    override suspend fun refreshLibrary(
        apiKey: String,
        language: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit> = Result.success(Unit)
}
