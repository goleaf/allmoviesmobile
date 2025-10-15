package dev.tutushkin.allmovies.presentation.movies.viewmodel

import android.content.Context
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import androidx.test.core.app.ApplicationProvider
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class MoviesViewModelTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val dispatcher = StandardTestDispatcher()
    private lateinit var repository: FakeMoviesRepository
    private lateinit var languagePreferences: LanguagePreferences

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        repository = FakeMoviesRepository()
        val context = ApplicationProvider.getApplicationContext<Context>()
        languagePreferences = LanguagePreferences(context)
        languagePreferences.setSelectedLanguage("en")
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `emits empty state when repository returns empty now playing`() = runTest(dispatcher) {
        repository.nowPlayingResult = Result.success(emptyList())

        val viewModel = MoviesViewModel(repository, languagePreferences)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(emittedStates.isNotEmpty())
        val resultState = emittedStates.last()
        assertTrue(resultState is MoviesState.Empty)
        assertEquals(MoviesState.EmptyReason.NOW_PLAYING, (resultState as MoviesState.Empty).reason)
        assertTrue(repository.clearAllCalled)
        assertTrue(repository.configurationRequested)
        assertTrue(repository.genresRequested)
        assertTrue(repository.nowPlayingRequested)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `toggleFavorite updates movie list`() = runTest(dispatcher) {
        val initialMovie = MovieList(id = 5, title = "Movie", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.setFavoriteResult = Result.success(Unit)

        val viewModel = MoviesViewModel(repository, languagePreferences)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        viewModel.toggleFavorite(initialMovie.id, true)
        dispatcher.scheduler.advanceUntilIdle()

        val resultState = emittedStates.last() as MoviesState.Result
        assertTrue(resultState.result.first().isFavorite)
        assertTrue(repository.setFavoriteCalledWith == (initialMovie.id to true))

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `search with blank query restores cached now playing`() = runTest(dispatcher) {
        val initialMovie = MovieList(id = 1, title = "Movie")
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.searchMoviesResult = Result.success(emptyList())

        val viewModel = MoviesViewModel(repository, languagePreferences)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        emittedStates.clear()

        viewModel.search("   ")

        val resultState = emittedStates.last() as MoviesState.Result
        assertEquals(listOf(initialMovie), resultState.result)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `search emits empty state when repository returns no matches`() = runTest(dispatcher) {
        val initialMovie = MovieList(id = 1, title = "Movie")
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.searchMoviesResult = Result.success(emptyList())

        val viewModel = MoviesViewModel(repository, languagePreferences)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        emittedStates.clear()

        viewModel.search("Matrix")
        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(emittedStates.first() is MoviesState.Searching)
        val emptyState = emittedStates.last() as MoviesState.Empty
        assertEquals(MoviesState.EmptyReason.SEARCH, emptyState.reason)
        assertEquals("Matrix", emptyState.query)
        assertEquals("Matrix", repository.searchMoviesRequested?.third)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `search emits results from repository`() = runTest(dispatcher) {
        val initialMovie = MovieList(id = 1, title = "Movie")
        val searchedMovie = MovieList(id = 2, title = "Searched")
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.searchMoviesResult = Result.success(listOf(searchedMovie))

        val viewModel = MoviesViewModel(repository, languagePreferences)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        emittedStates.clear()

        viewModel.search("Search")
        dispatcher.scheduler.advanceUntilIdle()

        val resultState = emittedStates.last() as MoviesState.Result
        assertEquals(listOf(searchedMovie), resultState.result)
        assertEquals("Search", repository.searchMoviesRequested?.third)

        viewModel.movies.removeObserver(observer)
    }
}

private class FakeMoviesRepository : MoviesRepository {

    var configurationResult: Result<Configuration> = Result.success(Configuration())
    var genresResult: Result<List<Genre>> = Result.success(emptyList())
    var nowPlayingResult: Result<List<MovieList>> = Result.success(emptyList())
    var movieDetailsResult: Result<MovieDetails> = Result.failure(UnsupportedOperationException())
    var favoritesResult: Result<List<MovieList>> = Result.success(emptyList())
    var setFavoriteResult: Result<Unit> = Result.success(Unit)
    var searchMoviesResult: Result<List<MovieList>> = Result.success(emptyList())

    var clearAllCalled: Boolean = false
        private set
    var configurationRequested: Boolean = false
        private set
    var genresRequested: Boolean = false
        private set
    var nowPlayingRequested: Boolean = false
        private set
    var setFavoriteCalledWith: Pair<Int, Boolean>? = null
    var searchMoviesRequested: Triple<String, String, String>? = null

    override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
        configurationRequested = true
        return configurationResult
    }

    override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
        genresRequested = true
        return genresResult
    }

    override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
        nowPlayingRequested = true
        return nowPlayingResult
    }

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String
    ): Result<List<MovieList>> {
        searchMoviesRequested = Triple(apiKey, language, query)
        return searchMoviesResult
    }

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String,
        ensureCached: Boolean
    ): Result<MovieDetails> {
        return movieDetailsResult
    }

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> {
        setFavoriteCalledWith = movieId to isFavorite
        return setFavoriteResult
    }

    override suspend fun getFavorites(): Result<List<MovieList>> = favoritesResult

    override suspend fun clearAll() {
        clearAllCalled = true
    }

    override suspend fun refreshLibrary(
        apiKey: String,
        language: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit> = Result.success(Unit)
}
