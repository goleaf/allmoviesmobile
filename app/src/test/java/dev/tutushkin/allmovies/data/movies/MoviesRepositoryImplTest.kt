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

    private companion object {
        private const val LANGUAGE = "en"
    }

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

        val result = repository.getNowPlaying("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals(1, remoteDataSource.nowPlayingCallCount)
        assertEquals("provided-key", remoteDataSource.lastNowPlayingApiKey)
        assertEquals(1, localDataSource.getNowPlaying().size)

        remoteDataSource.resetCallCounters()

        val cachedResult = repository.getNowPlaying("provided-key", LANGUAGE)

        assertTrue(cachedResult.isSuccess)
        assertEquals(0, remoteDataSource.nowPlayingCallCount)
        assertEquals(1, localDataSource.getNowPlaying().size)
    }

    @Test
    fun `getNowPlaying returns success with empty list when remote data empty`() = runTest(dispatcher) {
        remoteDataSource.nowPlayingResult = Result.success(emptyList())

        val result = repository.getNowPlaying("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertTrue(result.getOrThrow().isEmpty())
        assertTrue(localDataSource.getNowPlaying().isEmpty())
    }

    @Test
    fun `getNowPlaying preserves favorite flags from cached details`() = runTest(dispatcher) {
        val movieId = 200
        localDataSource.setMovieDetails(
            MovieDetailsEntity(
                id = movieId,
                title = "Favorite Movie",
                overview = "Overview",
                poster = "poster",
                backdrop = "backdrop",
                ratings = 7.5f,
                numberOfRatings = 99,
                minimumAge = "13+",
                year = "2023",
                runtime = 120,
                genres = "Action",
                isFavorite = true
            )
        )
        remoteDataSource.nowPlayingResult = Result.success(
            listOf(
                MovieListDto(
                    id = movieId,
                    title = "Favorite Movie",
                    posterPath = "/poster.jpg",
                    voteAverage = 7.5f,
                    voteCount = 99,
                    adult = false,
                    releaseDate = "2023-01-01",
                    genreIds = emptyList()
                )
            )
        )

        val result = repository.getNowPlaying("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertTrue(result.getOrThrow().first().isFavorite)
    }

    @Test
    fun `getGenres returns success with empty list when remote data empty`() = runTest(dispatcher) {
        remoteDataSource.genresResult = Result.success(emptyList())

        val result = repository.getGenres("provided-key", LANGUAGE)

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

        val result = repository.getMovieDetails(movieId, "api", LANGUAGE)

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

        val result = repository.getMovieDetails(movieId, "api", LANGUAGE)

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

        val result = repository.getMovieDetails(movieId, "api", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals(0, remoteDataSource.movieDetailsCallCount)
        assertEquals(0, remoteDataSource.actorsCallCount)
        assertEquals(2, result.getOrThrow().actors.size)
    }

    @Test
    fun `setFavorite updates local caches`() = runTest(dispatcher) {
        val movieId = 42
        val summary = MovieListEntity(
            id = movieId,
            title = "Summary",
            poster = "poster",
            ratings = 6.0f,
            numberOfRatings = 10,
            minimumAge = "13+",
            year = "2022",
            genres = "Drama",
            isFavorite = false
        )
        val details = MovieDetailsEntity(
            id = movieId,
            title = "Details",
            overview = "Overview",
            poster = "poster",
            backdrop = "backdrop",
            ratings = 6.0f,
            numberOfRatings = 10,
            minimumAge = "13+",
            year = "2022",
            runtime = 100,
            genres = "Drama",
            isFavorite = false
        )
        localDataSource.setMovie(summary)
        localDataSource.setMovieDetails(details)

        val result = repository.setFavorite(movieId, true)

        assertTrue(result.isSuccess)
        assertTrue(localDataSource.getMovie(movieId)?.isFavorite == true)
        assertTrue(localDataSource.getMovieDetails(movieId)?.isFavorite == true)
    }

    @Test
    fun `getFavorites returns favorites from summaries and details`() = runTest(dispatcher) {
        val summaryFavorite = MovieListEntity(
            id = 1,
            title = "Summary Favorite",
            poster = "poster",
            ratings = 8.0f,
            numberOfRatings = 80,
            minimumAge = "13+",
            year = "2021",
            genres = "Action",
            isFavorite = true
        )
        val detailOnlyFavorite = MovieDetailsEntity(
            id = 2,
            title = "Detail Favorite",
            overview = "Overview",
            poster = "poster",
            backdrop = "backdrop",
            ratings = 7.0f,
            numberOfRatings = 70,
            minimumAge = "13+",
            year = "2020",
            runtime = 110,
            genres = "Comedy",
            isFavorite = true
        )

        localDataSource.setMovie(summaryFavorite)
        localDataSource.setMovieDetails(detailOnlyFavorite)

        val result = repository.getFavorites()

        assertTrue(result.isSuccess)
        val favorites = result.getOrThrow()
        assertEquals(2, favorites.size)
        assertTrue(favorites.any { it.id == summaryFavorite.id })
        assertTrue(favorites.any { it.id == detailOnlyFavorite.id })
    }
}

private class FakeMoviesRemoteDataSource : MoviesRemoteDataSource {

    var configurationResult: Result<ConfigurationDto> = Result.failure(UnsupportedOperationException())
    var genresResult: Result<List<GenreDto>> = Result.failure(UnsupportedOperationException())
    var nowPlayingResult: Result<List<MovieListDto>> = Result.failure(UnsupportedOperationException())
    var searchResult: Result<List<MovieListDto>> = Result.failure(UnsupportedOperationException())
    var movieDetailsResult: Result<MovieDetailsResponse> = Result.failure(UnsupportedOperationException())
    var actorsResult: Result<List<MovieActorDto>> = Result.failure(UnsupportedOperationException())

    var nowPlayingCallCount: Int = 0
        private set
    var lastNowPlayingApiKey: String? = null
    var lastNowPlayingLanguage: String? = null
    var movieDetailsCallCount: Int = 0
        private set
    var actorsCallCount: Int = 0
        private set

    override suspend fun getConfiguration(apiKey: String, language: String): Result<ConfigurationDto> =
        configurationResult

    override suspend fun getGenres(apiKey: String, language: String): Result<List<GenreDto>> = genresResult

    override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieListDto>> {
        nowPlayingCallCount++
        lastNowPlayingApiKey = apiKey
        lastNowPlayingLanguage = language
        return nowPlayingResult
    }

    override suspend fun searchMovies(
        apiKey: String,
        language: String,
        query: String,
        includeAdult: Boolean,
    ): Result<List<MovieListDto>> = searchResult

    override suspend fun getMovieDetails(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<MovieDetailsResponse> {
        movieDetailsCallCount++
        return movieDetailsResult
    }

    override suspend fun getActors(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieActorDto>> {
        actorsCallCount++
        return actorsResult
    }

    fun resetCallCounters() {
        nowPlayingCallCount = 0
        lastNowPlayingApiKey = null
        lastNowPlayingLanguage = null
        movieDetailsCallCount = 0
        actorsCallCount = 0
    }
}

private class FakeMoviesLocalDataSource : MoviesLocalDataSource {

    private var configuration: ConfigurationEntity? = null
    private var genres: List<GenreEntity> = emptyList()
    private val movies = mutableMapOf<Int, MovieListEntity>()
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

    override suspend fun getNowPlaying(): List<MovieListEntity> = movies.values.toList()

    override suspend fun setNowPlaying(movies: List<MovieListEntity>) {
        movies.forEach { this.movies[it.id] = it }
    }

    override suspend fun clearNowPlaying() {
        movies.clear()
    }

    override suspend fun getMovieDetails(id: Int): MovieDetailsEntity? = movieDetails[id]

    override suspend fun setMovieDetails(movie: MovieDetailsEntity): Long {
        movieDetails[movie.id] = movie
        return movie.id.toLong()
    }

    override suspend fun getFavoriteMovieDetails(): List<MovieDetailsEntity> =
        movieDetails.values.filter { it.isFavorite }

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

    override suspend fun setMovie(movie: MovieListEntity) {
        movies[movie.id] = movie
    }

    override suspend fun getMovie(movieId: Int): MovieListEntity? = movies[movieId]

    override suspend fun getFavoriteMovies(): List<MovieListEntity> =
        movies.values.filter { it.isFavorite }

    override suspend fun getFavoriteMovieIds(): Set<Int> =
        (getFavoriteMovies().map { it.id } + getFavoriteMovieDetails().map { it.id }).toSet()

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean) {
        movies[movieId]?.let { movies[movieId] = it.copy(isFavorite = isFavorite) }
        movieDetails[movieId]?.let { movieDetails[movieId] = it.copy(isFavorite = isFavorite) }

        if (!movies.containsKey(movieId)) {
            movieDetails[movieId]?.let { details ->
                movies[movieId] = MovieListEntity(
                    id = details.id,
                    title = details.title,
                    poster = details.poster,
                    ratings = details.ratings,
                    numberOfRatings = details.numberOfRatings,
                    minimumAge = details.minimumAge,
                    year = details.year,
                    genres = details.genres,
                    isFavorite = isFavorite
                )
            }
        }
    }
}
