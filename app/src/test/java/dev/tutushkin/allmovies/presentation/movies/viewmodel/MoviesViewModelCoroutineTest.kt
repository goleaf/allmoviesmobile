package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import dev.tutushkin.allmovies.data.settings.LanguagePreferencesDataSource
import dev.tutushkin.allmovies.presentation.favorites.TestFavoritesUpdateNotifier
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
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
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class MoviesViewModelCoroutineTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private val dispatcher = StandardTestDispatcher()
    private lateinit var repository: CoroutineFakeMoviesRepository
    private lateinit var languagePreferences: FakeLanguagePreferences

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        repository = CoroutineFakeMoviesRepository()
        languagePreferences = FakeLanguagePreferences(initial = "en")
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `init emits loading then result when repository succeeds`() = runTest {
        val movies = listOf(
            MovieList(id = 1, title = "One"),
            MovieList(id = 2, title = "Two")
        )
        repository.nowPlayingResult = Result.success(movies)

        val viewModel = createViewModel()
        val observer = RecordingObserver<MoviesState>()
        viewModel.movies.observeForever(observer)

        dispatcher.scheduler.advanceUntilIdle()

        assertEquals(
            listOf(
                MoviesState.Loading,
                MoviesState.Result(movies)
            ),
            observer.values
        )
        assertEquals(1, repository.clearAllCallCount)
        assertEquals(listOf("en"), repository.nowPlayingLanguages)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `changeLanguage clears caches and reloads when code changes`() = runTest {
        val initialMovies = listOf(MovieList(id = 7, title = "English"))
        val spanishMovies = listOf(MovieList(id = 7, title = "Español"))
        repository.nowPlayingResult = Result.success(initialMovies)

        val viewModel = createViewModel()
        val observer = RecordingObserver<MoviesState>()
        viewModel.movies.observeForever(observer)
        dispatcher.scheduler.advanceUntilIdle()

        repository.nowPlayingResult = Result.success(spanishMovies)

        viewModel.changeLanguage("es")
        dispatcher.scheduler.advanceUntilIdle()

        assertEquals(2, repository.clearAllCallCount)
        assertEquals(listOf("en", "es"), repository.nowPlayingLanguages)

        val results = observer.values.filterIsInstance<MoviesState.Result>()
        assertEquals(listOf(initialMovies, spanishMovies), results.map { it.result })

        val clearAllCallsAfterSameLanguage = repository.clearAllCallCount
        viewModel.changeLanguage("es")
        dispatcher.scheduler.advanceUntilIdle()
        assertEquals(clearAllCallsAfterSameLanguage, repository.clearAllCallCount)

        viewModel.movies.removeObserver(observer)
    }

    @Test
    fun `toggleFavorite updates list and handles repository failures`() = runTest {
        val movie = MovieList(id = 42, title = "Favorite", isFavorite = false)
        repository.nowPlayingResult = Result.success(listOf(movie))

        val viewModel = createViewModel()
        val observer = RecordingObserver<MoviesState>()
        viewModel.movies.observeForever(observer)
        dispatcher.scheduler.advanceUntilIdle()

        var favoriteToggleResult: Boolean? = null
        repository.setFavoriteResult = Result.success(Unit)
        viewModel.toggleFavorite(movie.id, true) { favoriteToggleResult = it }
        dispatcher.scheduler.advanceUntilIdle()

        assertEquals(listOf(movie.id to true), repository.setFavoriteCalls)
        val updatedState = observer.values.last() as MoviesState.Result
        assertTrue(updatedState.result.first().isFavorite)
        assertTrue(favoriteToggleResult!!)

        val previousState = observer.values.last()
        repository.setFavoriteResult = Result.failure(IllegalStateException("network"))
        viewModel.toggleFavorite(movie.id, false) { favoriteToggleResult = it }
        dispatcher.scheduler.advanceUntilIdle()

        assertEquals(listOf(movie.id to true, movie.id to false), repository.setFavoriteCalls)
        assertSame(previousState, observer.values.last())
        assertFalse(favoriteToggleResult!!)

        viewModel.movies.removeObserver(observer)
    }

    private fun createViewModel() = MoviesViewModel(
        repository,
        languagePreferences,
        TestFavoritesUpdateNotifier()
    )
}

private class RecordingObserver<T> : Observer<T> {
    val values = mutableListOf<T>()
    override fun onChanged(value: T) {
        values.add(value)
    }
}

private class FakeLanguagePreferences(initial: String) : LanguagePreferencesDataSource {
    private var selected: String = initial
    var getSelectedLanguageCallCount: Int = 0
        private set
    var setSelectedLanguageCallCount: Int = 0
        private set

    override fun getSelectedLanguage(): String {
        getSelectedLanguageCallCount++
        return selected
    }

    override fun setSelectedLanguage(code: String) {
        selected = code
        setSelectedLanguageCallCount++
    }
}

private class CoroutineFakeMoviesRepository : MoviesRepository {
    var configurationResult: Result<Configuration> = Result.success(Configuration())
    var genresResult: Result<List<Genre>> = Result.success(emptyList())
    var nowPlayingResult: Result<List<MovieList>> = Result.success(emptyList())
    var setFavoriteResult: Result<Unit> = Result.success(Unit)

    var clearAllCallCount: Int = 0
        private set
    val configurationLanguages = mutableListOf<String>()
    val genresLanguages = mutableListOf<String>()
    val nowPlayingLanguages = mutableListOf<String>()
    val setFavoriteCalls = mutableListOf<Pair<Int, Boolean>>()

    override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
        configurationLanguages += language
        return configurationResult
    }

    override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
        genresLanguages += language
        return genresResult
    }

    override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
        nowPlayingLanguages += language
        return nowPlayingResult
    }

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String,
        includeAdult: Boolean
    ): Result<List<MovieList>> = throw UnsupportedOperationException()

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String,
        ensureCached: Boolean
    ): Result<MovieDetails> = throw UnsupportedOperationException()

    override suspend fun getActorDetails(
        actorId: Int,
        apiKey: String,
        language: String
    ): Result<ActorDetails> = throw UnsupportedOperationException()

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> {
        setFavoriteCalls += movieId to isFavorite
        return setFavoriteResult
    }

    override suspend fun getFavorites(): Result<List<MovieList>> = throw UnsupportedOperationException()

    override suspend fun clearAll() {
        clearAllCallCount++
    }

    override suspend fun refreshLibrary(
        apiKey: String,
        language: String,
        onProgress: (current: Int, total: Int, title: String) -> Unit
    ): Result<Unit> = throw UnsupportedOperationException()
}
