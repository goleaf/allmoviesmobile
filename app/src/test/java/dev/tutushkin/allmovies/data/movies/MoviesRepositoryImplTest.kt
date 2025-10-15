package dev.tutushkin.allmovies.data.movies

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.mutablePreferencesOf
import androidx.datastore.preferences.core.stringPreferencesKey
import dev.tutushkin.allmovies.data.movies.CertificationValue
import dev.tutushkin.allmovies.data.movies.fallbackCertification
import dev.tutushkin.allmovies.data.movies.local.ActorEntity
import dev.tutushkin.allmovies.data.movies.local.ActorDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.ConfigurationDataStore
import dev.tutushkin.allmovies.data.movies.local.ConfigurationEntity
import dev.tutushkin.allmovies.data.movies.local.GenreEntity
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSource
import dev.tutushkin.allmovies.data.movies.remote.ActorDetailsResponse
import dev.tutushkin.allmovies.data.movies.remote.ActorMovieCreditsResponse
import dev.tutushkin.allmovies.data.movies.remote.ConfigurationDto
import dev.tutushkin.allmovies.data.movies.remote.GenreDto
import dev.tutushkin.allmovies.data.movies.remote.MovieActorDto
import dev.tutushkin.allmovies.data.movies.remote.MovieDetailsResponse
import dev.tutushkin.allmovies.data.movies.remote.MovieListDto
import dev.tutushkin.allmovies.data.movies.remote.MovieReleaseDatesResponse
import dev.tutushkin.allmovies.data.movies.remote.MovieVideoDto
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSource
import dev.tutushkin.allmovies.data.movies.remote.ReleaseDateDto
import dev.tutushkin.allmovies.data.movies.remote.ReleaseDatesCountryDto
import dev.tutushkin.allmovies.domain.movies.models.Certification
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
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
    private lateinit var configurationDataStore: ConfigurationDataStore
    private lateinit var inMemoryDataStore: InMemoryPreferencesDataStore
    private lateinit var repository: MoviesRepositoryImpl

    private companion object {
        private const val LANGUAGE = "en"
    }

    private val generalCertification = fallbackCertification(false)
    private val adultCertification = fallbackCertification(true)

    @Before
    fun setUp() = runTest {
        remoteDataSource = FakeMoviesRemoteDataSource()
        localDataSource = FakeMoviesLocalDataSource()
        inMemoryDataStore = InMemoryPreferencesDataStore()
        configurationDataStore = ConfigurationDataStore(inMemoryDataStore)
        configurationDataStore.write(Configuration(imagesBaseUrl = "https://images.test/"))
        repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, configurationDataStore, dispatcher)
    }

    @Test
    fun `getConfiguration returns stored configuration without hitting remote`() = runTest(dispatcher) {
        remoteDataSource.configurationResult = Result.failure(IllegalStateException("not expected"))
        remoteDataSource.resetCallCounters()

        val result = repository.getConfiguration("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals("https://images.test/", result.getOrThrow().imagesBaseUrl)
        assertEquals(0, remoteDataSource.configurationCallCount)
    }

    @Test
    fun `getConfiguration fetches remote when cache empty and saves it`() = runTest(dispatcher) {
        inMemoryDataStore.updateData { emptyPreferences() }
        remoteDataSource.configurationResult = Result.success(
            ConfigurationDto(
                imagesBaseUrl = "https://remote/",
                posterSizes = listOf("w500"),
                backdropSizes = listOf("w1280"),
                profileSizes = listOf("w300")
            )
        )
        remoteDataSource.resetCallCounters()

        val result = repository.getConfiguration("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals("https://remote/", result.getOrThrow().imagesBaseUrl)
        assertEquals(1, remoteDataSource.configurationCallCount)
        assertEquals("https://remote/", configurationDataStore.read()?.imagesBaseUrl)
    }

    @Test
    fun `getConfiguration falls back to defaults when cache corrupt and remote fails`() = runTest(dispatcher) {
        val key = stringPreferencesKey("configuration_json")
        inMemoryDataStore.updateData { mutablePreferencesOf(key to "{not-json}") }
        remoteDataSource.configurationResult = Result.failure(IllegalStateException("boom"))
        remoteDataSource.resetCallCounters()

        val result = repository.getConfiguration("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals(Configuration().imagesBaseUrl, result.getOrThrow().imagesBaseUrl)
        assertEquals(1, remoteDataSource.configurationCallCount)
    }

    @Test
    fun `getConfiguration falls back to defaults when cache empty and remote fails`() = runTest(dispatcher) {
        inMemoryDataStore.updateData { emptyPreferences() }
        remoteDataSource.configurationResult = Result.failure(IllegalStateException("boom"))
        remoteDataSource.resetCallCounters()

        val result = repository.getConfiguration("provided-key", LANGUAGE)

        assertTrue(result.isSuccess)
        assertEquals(Configuration().imagesBaseUrl, result.getOrThrow().imagesBaseUrl)
        assertEquals(1, remoteDataSource.configurationCallCount)
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
                certificationLabel = generalCertification.label,
                certificationCode = generalCertification.code,
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
    fun `searchMovies merges favorites from local cache`() = runTest(dispatcher) {
        val favoriteId = 301
        localDataSource.setMovie(
            MovieListEntity(
                id = favoriteId,
                title = "Favorite",
                poster = "poster",
                ratings = 8.0f,
                numberOfRatings = 80,
                certificationLabel = generalCertification.label,
                certificationCode = generalCertification.code,
                year = "2024",
                genres = "Sci-Fi",
                isFavorite = true
            )
        )

        remoteDataSource.searchResult = Result.success(
            listOf(
                MovieListDto(
                    id = favoriteId,
                    title = "Favorite",
                    posterPath = "/poster.jpg",
                    voteAverage = 8.0f,
                    voteCount = 80,
                    adult = false,
                    releaseDate = "2024-01-01",
                    genreIds = emptyList()
                )
            )
        )

        val result = repository.searchMovies("api", LANGUAGE, "Fav")

        assertTrue(result.isSuccess)
        val movies = result.getOrThrow()
        assertEquals(1, movies.size)
        assertTrue(movies.first().isFavorite)
    }

    @Test
    fun `searchMovies propagates failures`() = runTest(dispatcher) {
        val error = IllegalStateException("search failed")
        remoteDataSource.searchResult = Result.failure(error)

        val result = repository.searchMovies("api", LANGUAGE, "Oops")

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull() === error)
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
    fun `getMovieDetails uses release dates certification when available`() = runTest(dispatcher) {
        val movieId = 12
        remoteDataSource.movieDetailsResult = Result.success(
            MovieDetailsResponse(
                id = movieId,
                title = "Movie",
                overview = "Overview",
                backdropPath = "/backdrop.jpg",
                voteAverage = 7.0f,
                voteCount = 50,
                adult = false,
                releaseDate = "2021-06-01",
                runtime = 110,
                genres = listOf(GenreDto(1, "Action"))
            )
        )
        remoteDataSource.releaseDatesResult = Result.success(
            MovieReleaseDatesResponse(
                results = listOf(
                    ReleaseDatesCountryDto(
                        countryCode = "US",
                        releaseDates = listOf(
                            ReleaseDateDto(certification = "PG-13", languageCode = "en")
                        )
                    )
                )
            )
        )
        remoteDataSource.actorsResult = Result.success(emptyList())

        val result = repository.getMovieDetails(movieId, "api", "en-US")

        assertTrue(result.isSuccess)
        val certification = result.getOrThrow().certification
        assertEquals("PG-13", certification.code)
        assertEquals("PG-13", certification.label)
        assertEquals(1, remoteDataSource.releaseDatesCallCount)
    }

    @Test
    fun `getMovieDetails falls back to adult certification when release dates missing`() = runTest(dispatcher) {
        val movieId = 13
        remoteDataSource.movieDetailsResult = Result.success(
            MovieDetailsResponse(
                id = movieId,
                title = "Movie",
                overview = "Overview",
                backdropPath = "/backdrop.jpg",
                voteAverage = 7.0f,
                voteCount = 50,
                adult = true,
                releaseDate = "2021-06-01",
                runtime = 110,
                genres = listOf(GenreDto(1, "Action"))
            )
        )
        remoteDataSource.releaseDatesResult = Result.success(MovieReleaseDatesResponse(emptyList()))
        remoteDataSource.actorsResult = Result.success(emptyList())

        val result = repository.getMovieDetails(movieId, "api", LANGUAGE)

        assertTrue(result.isSuccess)
        val certification = result.getOrThrow().certification
        assertEquals(adultCertification.code, certification.code)
        assertEquals(adultCertification.label, certification.label)
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
            certificationLabel = generalCertification.label,
            certificationCode = generalCertification.code,
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
            certificationLabel = generalCertification.label,
            certificationCode = generalCertification.code,
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
            certificationLabel = generalCertification.label,
            certificationCode = generalCertification.code,
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
            certificationLabel = generalCertification.label,
            certificationCode = generalCertification.code,
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
            certificationLabel = generalCertification.label,
            certificationCode = generalCertification.code,
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
    var releaseDatesResult: Result<MovieReleaseDatesResponse> = Result.success(
        MovieReleaseDatesResponse(emptyList())
    )

    var configurationCallCount: Int = 0
        private set
    var nowPlayingCallCount: Int = 0
        private set
    var lastNowPlayingApiKey: String? = null
    var lastNowPlayingLanguage: String? = null
    var movieDetailsCallCount: Int = 0
        private set
    var actorsCallCount: Int = 0
        private set
    var releaseDatesCallCount: Int = 0
        private set

    override suspend fun getConfiguration(apiKey: String, language: String): Result<ConfigurationDto> {
        configurationCallCount++
        return configurationResult
    }

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

    override suspend fun getMovieReleaseDates(
        movieId: Int,
        apiKey: String,
    ): Result<MovieReleaseDatesResponse> {
        releaseDatesCallCount++
        return releaseDatesResult
    }

    override suspend fun getActors(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieActorDto>> {
        actorsCallCount++
        return actorsResult
    }

    override suspend fun getVideos(
        movieId: Int,
        apiKey: String,
        language: String
    ): Result<List<MovieVideoDto>> = Result.success(emptyList())

    override suspend fun getActorDetails(
        actorId: Int,
        apiKey: String,
        language: String
    ): Result<ActorDetailsResponse> = Result.failure(UnsupportedOperationException())

    override suspend fun getActorMovieCredits(
        actorId: Int,
        apiKey: String,
        language: String
    ): Result<ActorMovieCreditsResponse> = Result.success(
        ActorMovieCreditsResponse(id = actorId, cast = emptyList(), crew = emptyList())
    )

    fun resetCallCounters() {
        configurationCallCount = 0
        nowPlayingCallCount = 0
        lastNowPlayingApiKey = null
        lastNowPlayingLanguage = null
        movieDetailsCallCount = 0
        actorsCallCount = 0
        releaseDatesCallCount = 0
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

    override suspend fun getAllMovieDetails(): List<MovieDetailsEntity> =
        movieDetails.values.toList()

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

    override suspend fun getActorDetails(actorId: Int): ActorDetailsEntity? = null

    override suspend fun setActorDetails(actorDetails: ActorDetailsEntity) { /* no-op for tests */ }

    override suspend fun clearActorDetails() { /* no-op for tests */ }

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
                    certificationLabel = details.certificationLabel,
                    certificationCode = details.certificationCode,
                    year = details.year,
                    genres = details.genres,
                    isFavorite = isFavorite
                )
            }
        }
    }
}

private class InMemoryPreferencesDataStore(
    initialPreferences: Preferences = emptyPreferences()
) : DataStore<Preferences> {

    private val state = MutableStateFlow(initialPreferences)

    override val data: Flow<Preferences> = state

    override suspend fun updateData(transform: suspend (t: Preferences) -> Preferences): Preferences {
        val updated = transform(state.value)
        state.value = updated
        return updated
    }
}
