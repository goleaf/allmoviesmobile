package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Certification
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.TestLanguagePreferences
import dev.tutushkin.allmovies.presentation.TestLogger
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalytics
import dev.tutushkin.allmovies.presentation.common.UiText
import dev.tutushkin.allmovies.presentation.favorites.TestFavoritesUpdateNotifier
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsState
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
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
    private lateinit var languagePreferences: TestLanguagePreferences
    private lateinit var favoritesNotifier: TestFavoritesUpdateNotifier
    private lateinit var logger: TestLogger

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        repository = FakeMoviesRepository()
        languagePreferences = TestLanguagePreferences("en")
        favoritesNotifier = TestFavoritesUpdateNotifier()
        logger = TestLogger()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `emits empty result when repository returns empty now playing`() = runTest(dispatcher) {
        repository.nowPlayingResult = Result.success(emptyList())

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(emittedStates.isNotEmpty())
        val resultState = emittedStates.last()
        assertTrue(resultState is MoviesState.Result)
        assertTrue((resultState as MoviesState.Result).result.isEmpty())
        assertTrue(repository.clearAllCalled)
        assertTrue(repository.configurationRequested)
        assertTrue(repository.genresRequested)
        assertTrue(repository.nowPlayingRequested)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `emits error when repository fails to load now playing`() = runTest(dispatcher) {
        val error = IllegalStateException("boom")
        repository.nowPlayingResult = Result.failure(error)

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        val lastState = emittedStates.last()
        assertTrue(lastState is MoviesState.Error)
        val uiText = (lastState as MoviesState.Error).message
        assertTrue(uiText is UiText.Resource)
        assertTrue((uiText as UiText.Resource).resId == R.string.movies_list_error_generic)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `toggleFavorite updates movie list`() = runTest(dispatcher) {
        val initialMovie = MovieList(id = 5, title = "Movie", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.setFavoriteResult = Result.success(Unit)

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
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
    fun `changeLanguage keeps favorites marked`() = runTest(dispatcher) {
        val movieId = 42
        val initialMovie = MovieList(id = movieId, title = "Movie", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.setFavoriteResult = Result.success(Unit)

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        viewModel.toggleFavorite(movieId, true)
        dispatcher.scheduler.advanceUntilIdle()

        val localizedMovie = initialMovie.copy(title = "Película", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(localizedMovie))

        viewModel.changeLanguage("es")
        dispatcher.scheduler.advanceUntilIdle()

        val lastResult = emittedStates.filterIsInstance<MoviesState.Result>().last()
        val refreshedMovie = lastResult.result.first { it.id == movieId }
        assertTrue(refreshedMovie.isFavorite)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `search triggers repository after debounce and reconciles favorites`() = runTest(dispatcher) {
        val movieId = 33
        val initialMovie = MovieList(id = movieId, title = "Star Journey", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.setFavoriteResult = Result.success(Unit)
        repository.searchMoviesResult = Result.success(listOf(initialMovie.copy(isFavorite = false)))

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val searchStates = mutableListOf<MoviesSearchState>()
        val observer = Observer<MoviesSearchState> { state -> searchStates.add(state) }
        viewModel.searchState.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        viewModel.toggleFavorite(movieId, true)
        dispatcher.scheduler.advanceUntilIdle()

        viewModel.observeSearch("Star")

        assertTrue(repository.searchMoviesCallCount == 0)

        dispatcher.scheduler.advanceTimeBy(MoviesViewModel.SEARCH_DEBOUNCE_MILLIS - 1)
        dispatcher.scheduler.runCurrent()
        assertTrue(repository.searchMoviesCallCount == 0)

        dispatcher.scheduler.advanceTimeBy(1)
        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(repository.searchMoviesCallCount == 1)
        val resultState = searchStates.last() as MoviesSearchState.Result
        assertTrue(resultState.result.first().isFavorite)

        viewModel.searchState.removeObserver(observer)
    }

    @Test
    fun `search emits error when repository fails`() = runTest(dispatcher) {
        repository.nowPlayingResult = Result.success(emptyList())
        val failure = IllegalStateException("network")
        repository.searchMoviesResult = Result.failure(failure)

        val viewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val searchStates = mutableListOf<MoviesSearchState>()
        val observer = Observer<MoviesSearchState> { state -> searchStates.add(state) }
        viewModel.searchState.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        viewModel.observeSearch("Broken")
        dispatcher.scheduler.advanceTimeBy(MoviesViewModel.SEARCH_DEBOUNCE_MILLIS)
        dispatcher.scheduler.advanceUntilIdle()

        val errorState = searchStates.last() as MoviesSearchState.Error
        assertTrue(errorState.query == "Broken")
        val message = errorState.message
        assertTrue(message is UiText.Resource)
        val resource = message as UiText.Resource
        assertTrue(resource.resId == R.string.movies_search_error_with_reason)
        assertTrue(resource.args.contains("Broken"))
        assertTrue(resource.args.contains("network"))

        viewModel.searchState.removeObserver(observer)
    }

    @Test
    fun `toggling favorite in details updates movies list`() = runTest(dispatcher) {
        val movieId = 7
        val initialMovie = MovieList(id = movieId, title = "Movie", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(initialMovie))
        repository.movieDetailsResult = Result.success(
            MovieDetails(
                id = movieId,
                title = "Movie",
                overview = "Overview",
                ratings = 7.5f,
                numberOfRatings = 50,
                runtime = 120,
                genres = "Drama",
                certification = Certification(code = "GENERAL", label = "13+"),
                isFavorite = false
            )
        )
        repository.setFavoriteResult = Result.success(Unit)

        val moviesViewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)
        val emittedStates = mutableListOf<MoviesState>()
        val observer = Observer<MoviesState> { state -> emittedStates.add(state) }
        moviesViewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        val detailsViewModel = MovieDetailsViewModel(
            repository,
            movieId,
            slug = null,
            openedFromSharedLink = false,
            analytics = FakeSharedLinkAnalytics,
            language = languagePreferences.getSelectedLanguage(),
            moviesViewModel = moviesViewModel
        )

        dispatcher.scheduler.advanceUntilIdle()

        detailsViewModel.toggleFavorite()
        dispatcher.scheduler.advanceUntilIdle()

        val listResult = emittedStates.filterIsInstance<MoviesState.Result>().last()
        val updatedMovie = listResult.result.first { it.id == movieId }
        assertTrue(updatedMovie.isFavorite)

        val currentMovieState = detailsViewModel.currentMovie.value as MovieDetailsState.Result
        assertTrue(currentMovieState.movie.isFavorite)
        assertTrue(repository.setFavoriteCalledWith == (movieId to true))

        moviesViewModel.movies.removeObserver(observer)
    }

    @Test
    fun `logs error when configuration fetch fails`() = runTest(dispatcher) {
        val failure = IllegalStateException("config boom")
        repository.configurationResult = Result.failure(failure)

        MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)

        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(
            logger.errors.any { entry ->
                entry.tag == "MoviesViewModel" &&
                    entry.message.contains("configuration") &&
                    entry.throwable === failure
            }
        )
    }

    @Test
    fun `logs error when genres fetch fails`() = runTest(dispatcher) {
        val failure = IllegalStateException("genres boom")
        repository.genresResult = Result.failure(failure)

        MoviesViewModel(repository, languagePreferences, favoritesNotifier, logger)

        dispatcher.scheduler.advanceUntilIdle()

        assertTrue(
            logger.errors.any { entry ->
                entry.tag == "MoviesViewModel" &&
                    entry.message.contains("genres") &&
                    entry.throwable === failure
            }
        )
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
    var clearAllCallCount: Int = 0
        private set
    var configurationRequested: Boolean = false
        private set
    var genresRequested: Boolean = false
        private set
    var nowPlayingRequested: Boolean = false
        private set
    var setFavoriteCalledWith: Pair<Int, Boolean>? = null
    var searchMoviesCallCount: Int = 0
        private set

    private val favoriteMovieIds = mutableSetOf<Int>()

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
        return nowPlayingResult.map { movies ->
            movies.map { movie ->
                val isFavorite = favoriteMovieIds.contains(movie.id) || movie.isFavorite
                if (movie.isFavorite == isFavorite) movie else movie.copy(isFavorite = isFavorite)
            }
        }
    }

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String,
        ensureCached: Boolean
    ): Result<MovieDetails> {
        return movieDetailsResult
    }

    override suspend fun getActorDetails(
        actorId: Int,
        apiKey: String,
        language: String
    ): Result<dev.tutushkin.allmovies.domain.movies.models.ActorDetails> =
        Result.failure(UnsupportedOperationException())

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> {
        setFavoriteCalledWith = movieId to isFavorite
        if (isFavorite) {
            favoriteMovieIds.add(movieId)
        } else {
            favoriteMovieIds.remove(movieId)
        }
        return setFavoriteResult
    }

    override suspend fun getFavorites(): Result<List<MovieList>> = favoritesResult

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String,
        includeAdult: Boolean
    ): Result<List<MovieList>> {
        searchMoviesCallCount++
        return searchMoviesResult
    }

    override suspend fun clearAll() {
        clearAllCalled = true
        clearAllCallCount++
    }

    override suspend fun refreshLibrary(
        apiKey: String,
        language: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit> = Result.success(Unit)
}

private object FakeSharedLinkAnalytics : SharedLinkAnalytics {
    override fun logSharedLinkOpened(movieId: Int, slug: String?) = Unit
}

