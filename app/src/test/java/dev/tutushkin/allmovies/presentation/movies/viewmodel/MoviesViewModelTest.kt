package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
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

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        repository = FakeMoviesRepository()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `emits empty result when repository returns empty now playing`() = runTest(dispatcher) {
        repository.nowPlayingResult = Result.success(emptyList())

        val viewModel = MoviesViewModel(repository)
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
}

private class FakeMoviesRepository : MoviesRepository {

    var configurationResult: Result<Configuration> = Result.success(Configuration())
    var genresResult: Result<List<Genre>> = Result.success(emptyList())
    var nowPlayingResult: Result<List<MovieList>> = Result.success(emptyList())
    var movieDetailsResult: Result<MovieDetails> = Result.failure(UnsupportedOperationException())

    var clearAllCalled: Boolean = false
        private set
    var configurationRequested: Boolean = false
        private set
    var genresRequested: Boolean = false
        private set
    var nowPlayingRequested: Boolean = false
        private set

    override suspend fun getConfiguration(apiKey: String): Result<Configuration> {
        configurationRequested = true
        return configurationResult
    }

    override suspend fun getGenres(apiKey: String): Result<List<Genre>> {
        genresRequested = true
        return genresResult
    }

    override suspend fun getNowPlaying(apiKey: String): Result<List<MovieList>> {
        nowPlayingRequested = true
        return nowPlayingResult
    }

    override suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetails> {
        return movieDetailsResult
    }

    override suspend fun clearAll() {
        clearAllCalled = true
    }
}
