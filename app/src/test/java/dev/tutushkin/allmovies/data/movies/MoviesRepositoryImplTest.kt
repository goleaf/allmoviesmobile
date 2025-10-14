package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.ActorEntity
import dev.tutushkin.allmovies.data.movies.local.ConfigurationEntity
import dev.tutushkin.allmovies.data.movies.local.GenreEntity
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSource
import dev.tutushkin.allmovies.data.movies.remote.ConfigurationDto
import dev.tutushkin.allmovies.data.movies.remote.GenreDto
import dev.tutushkin.allmovies.data.movies.remote.MovieActorDto
import dev.tutushkin.allmovies.data.movies.remote.MovieDetailsResponse
import dev.tutushkin.allmovies.data.movies.remote.MovieListDto
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSource
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class MoviesRepositoryImplTest {

    private val dispatcher: CoroutineDispatcher = StandardTestDispatcher()
    private lateinit var remoteDataSource: FakeMoviesRemoteDataSource
    private lateinit var localDataSource: FakeMoviesLocalDataSource
    private lateinit var repository: MoviesRepositoryImpl

    @Before
    fun setUp() {
        remoteDataSource = FakeMoviesRemoteDataSource()
        localDataSource = FakeMoviesLocalDataSource()
        repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, dispatcher)
    }

    @Test
    fun `getNowPlaying uses provided apiKey and caches remote response`() = runTest(dispatcher) {
        remoteDataSource.nowPlayingResult = Result.success(
            listOf(
                MovieListDto(
                    id = 100,
                    title = "Sample Movie",
                    posterPath = "/poster.jpg",
                    voteAverage = 7.0f,
                    voteCount = 10,
                    adult = false,
                    releaseDate = "2023-01-01",
                    genreIds = emptyList()
                )
            )
        )

        val result = repository.getNowPlaying("provided-key")

        assertTrue(result.isSuccess)
        assertEquals(1, remoteDataSource.nowPlayingCallCount)
        assertEquals("provided-key", remoteDataSource.lastNowPlayingApiKey)
        assertEquals(1, localDataSource.getNowPlaying().size)

        remoteDataSource.resetCallCounters()

        val cachedResult = repository.getNowPlaying("provided-key")

        assertTrue(cachedResult.isSuccess)
        assertEquals(0, remoteDataSource.nowPlayingCallCount)
        assertEquals(1, localDataSource.getNowPlaying().size)
    }

    @Test
    fun `getNowPlaying returns success with empty list when remote data empty`() = runTest(dispatcher) {
        remoteDataSource.nowPlayingResult = Result.success(emptyList())

        val result = repository.getNowPlaying("provided-key")

        assertTrue(result.isSuccess)
        assertTrue(result.getOrThrow().isEmpty())
        assertTrue(localDataSource.getNowPlaying().isEmpty())
    }

    @Test
    fun `getGenres returns success with empty list when remote data empty`() = runTest(dispatcher) {
        remoteDataSource.genresResult = Result.success(emptyList())

        val result = repository.getGenres("provided-key")

        assertTrue(result.isSuccess)
        assertTrue(result.getOrThrow().isEmpty())
        assertTrue(localDataSource.getGenres().isEmpty())
    }

    @Test
    fun `getMovieDetails caches actors after single remote request`() = runTest(dispatcher) {
        val movieId = 1
        remoteDataSource.movieDetailsResult = Result.success(
            MovieDetailsResponse(
                id = movieId,
                title = "Movie",
                overview = "Overview",
                backdropPath = "/backdrop.jpg",
                voteAverage = 8.0f,
                voteCount = 100,
                adult = false,
                releaseDate = "2020-01-01",
                runtime = 120,
                genres = listOf(GenreDto(1, "Action"))
            )
        )
        remoteDataSource.actorsResult = Result.success(
            listOf(
                MovieActorDto(id = 10, name = "Actor 1", profilePath = "/actor1.jpg"),
                MovieActorDto(id = 11, name = "Actor 2", profilePath = "/actor2.jpg")
            )
        )

        val result = repository.getMovieDetails(movieId, "api")

        assertTrue(result.isSuccess)
        assertEquals(1, remoteDataSource.movieDetailsCallCount)
        assertEquals(1, remoteDataSource.actorsCallCount)
        val storedMovie = localDataSource.getMovieDetails(movieId)
        assertNotNull(storedMovie)
        assertEquals(listOf(10, 11), storedMovie!!.actors)
        assertTrue(storedMovie.isActorsLoaded)
        assertEquals(2, result.getOrThrow().actors.size)
    }

    @Test
    fun `getMovieDetails returns success with empty actors when remote returns none`() = runTest(dispatcher) {
        val movieId = 3
        remoteDataSource.movieDetailsResult = Result.success(
            MovieDetailsResponse(
                id = movieId,
                title = "Movie",
                overview = "Overview",
                backdropPath = "/backdrop.jpg",
                voteAverage = 8.0f,
                voteCount = 100,
                adult = false,
                releaseDate = "2020-01-01",
                runtime = 120,
                genres = listOf(GenreDto(1, "Action"))
            )
        )
        remoteDataSource.actorsResult = Result.success(emptyList())

        val result = repository.getMovieDetails(movieId, "api")

        assertTrue(result.isSuccess)
        assertTrue(result.getOrThrow().actors.isEmpty())
        val storedMovie = localDataSource.getMovieDetails(movieId)
        assertNotNull(storedMovie)
        assertTrue(storedMovie!!.isActorsLoaded)
        assertTrue(storedMovie.actors.isEmpty())
    }

    @Test
    fun `getMovieDetails returns cached actors without additional remote call`() = runTest(dispatcher) {
        val movieId = 2
        val movieEntity = MovieDetailsEntity(
            id = movieId,
            title = "Movie",
            overview = "Overview",
            backdrop = "backdrop",
            ratings = 7.5f,
            numberOfRatings = 50,
            minimumAge = "13+",
            year = "2020",
            runtime = 100,
            genres = "Action",
            actors = listOf(20, 21),
            isActorsLoaded = true
        )
        localDataSource.setMovieDetails(movieEntity)
        localDataSource.setActors(
            listOf(
                ActorEntity(id = 20, name = "Actor 1", photo = "photo1"),
                ActorEntity(id = 21, name = "Actor 2", photo = "photo2")
            )
        )

        remoteDataSource.resetCallCounters()

        val result = repository.getMovieDetails(movieId, "api")

        assertTrue(result.isSuccess)
        assertEquals(0, remoteDataSource.movieDetailsCallCount)
        assertEquals(0, remoteDataSource.actorsCallCount)
        assertEquals(2, result.getOrThrow().actors.size)
    }
}

private class FakeMoviesRemoteDataSource : MoviesRemoteDataSource {

    var configurationResult: Result<ConfigurationDto> = Result.failure(UnsupportedOperationException())
    var genresResult: Result<List<GenreDto>> = Result.failure(UnsupportedOperationException())
    var nowPlayingResult: Result<List<MovieListDto>> = Result.failure(UnsupportedOperationException())
    var movieDetailsResult: Result<MovieDetailsResponse> = Result.failure(UnsupportedOperationException())
    var actorsResult: Result<List<MovieActorDto>> = Result.failure(UnsupportedOperationException())

    var nowPlayingCallCount: Int = 0
        private set
    var lastNowPlayingApiKey: String? = null
    var movieDetailsCallCount: Int = 0
        private set
    var actorsCallCount: Int = 0
        private set

    override suspend fun getConfiguration(apiKey: String): Result<ConfigurationDto> = configurationResult

    override suspend fun getGenres(apiKey: String): Result<List<GenreDto>> = genresResult

    override suspend fun getNowPlaying(apiKey: String): Result<List<MovieListDto>> {
        nowPlayingCallCount++
        lastNowPlayingApiKey = apiKey
        return nowPlayingResult
    }

    override suspend fun getMovieDetails(movieId: Int, apiKey: String): Result<MovieDetailsResponse> {
        movieDetailsCallCount++
        return movieDetailsResult
    }

    override suspend fun getActors(movieId: Int, apiKey: String): Result<List<MovieActorDto>> {
        actorsCallCount++
        return actorsResult
    }

    fun resetCallCounters() {
        nowPlayingCallCount = 0
        lastNowPlayingApiKey = null
        movieDetailsCallCount = 0
        actorsCallCount = 0
    }
}

private class FakeMoviesLocalDataSource : MoviesLocalDataSource {

    private var configuration: ConfigurationEntity? = null
    private var genres: List<GenreEntity> = emptyList()
    private var nowPlaying: List<MovieListEntity> = emptyList()
    private val movieDetails = mutableMapOf<Int, MovieDetailsEntity>()
    private val actors = mutableMapOf<Int, ActorEntity>()

    override suspend fun getConfiguration(): ConfigurationEntity? = configuration

    override suspend fun setConfiguration(configuration: ConfigurationEntity) {
        this.configuration = configuration
    }

    override suspend fun clearConfiguration() {
        configuration = null
    }

    override suspend fun getGenres(): List<GenreEntity> = genres

    override suspend fun setGenres(genres: List<GenreEntity>) {
        this.genres = genres
    }

    override suspend fun clearGenres() {
        genres = emptyList()
    }

    override suspend fun getNowPlaying(): List<MovieListEntity> = nowPlaying

    override suspend fun setNowPlaying(movies: List<MovieListEntity>) {
        nowPlaying = movies
    }

    override suspend fun clearNowPlaying() {
        nowPlaying = emptyList()
    }

    override suspend fun getMovieDetails(id: Int): MovieDetailsEntity? = movieDetails[id]

    override suspend fun setMovieDetails(movie: MovieDetailsEntity): Long {
        movieDetails[movie.id] = movie
        return movie.id.toLong()
    }

    override suspend fun clearMovieDetails() {
        movieDetails.clear()
    }

    override suspend fun getActors(actorsId: List<Int>): List<ActorEntity> =
        actorsId.mapNotNull { actors[it] }

    override suspend fun setActors(actors: List<ActorEntity>) {
        actors.forEach { this.actors[it.id] = it }
    }

    override suspend fun setActorsLoaded(movieId: Int) {
        movieDetails[movieId]?.let { existing ->
            movieDetails[movieId] = existing.copy(isActorsLoaded = true)
        }
    }

    override suspend fun clearActors() {
        actors.clear()
    }
}
