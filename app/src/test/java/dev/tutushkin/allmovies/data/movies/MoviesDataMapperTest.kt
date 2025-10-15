package dev.tutushkin.allmovies.data.movies

import android.content.Context
import android.net.ConnectivityManager
import androidx.test.core.app.ApplicationProvider
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.remote.GenreDto
import dev.tutushkin.allmovies.data.movies.remote.MovieActorDto
import dev.tutushkin.allmovies.data.movies.remote.MovieDetailsResponse
import dev.tutushkin.allmovies.data.movies.remote.MovieListDto
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MoviesDataMapperTest {

    private lateinit var imageSizeSelector: ImageSizeSelector

    @Before
    fun setUp() {
        NetworkModule.allGenres = listOf(Genre(id = 1, name = "Action"))
        val context = ApplicationProvider.getApplicationContext<Context>()
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        imageSizeSelector = ImageSizeSelector(
            connectivityManager = connectivityManager,
            configurationProvider = { NetworkModule.configApi },
            deviceWidthProvider = { 400 },
            bandwidthProvider = { 5_000 }
        )
    }

    @After
    fun tearDown() {
        NetworkModule.allGenres = emptyList()
    }

    @Test
    fun `movie list dto with null poster creates entity with empty poster`() {
        val dto = MovieListDto(
            id = 1,
            title = "Title",
            posterPath = null,
            voteAverage = 6.5f,
            voteCount = 100,
            adult = false,
            releaseDate = "2020-01-01",
            genreIds = listOf(1)
        )


        val entity = dto.toEntity(imageSizeSelector)

        val entity = dto.toEntity(imageSizeSelector)


        assertEquals("", entity.poster)
    }

    @Test
    fun `movie details response with blank backdrop creates entity with empty backdrop`() {
        val dto = MovieDetailsResponse(
            id = 2,
            title = "Details",
            overview = "Overview",
            backdropPath = " ",
            voteAverage = 7.4f,
            voteCount = 50,
            adult = false,
            releaseDate = "2021-05-01",
            runtime = 120,
            genres = listOf(GenreDto(id = 1, name = "Action"))
        )


        val entity = dto.toEntity(imageSizeSelector)

        val entity = dto.toEntity(imageSizeSelector)


        assertEquals("", entity.backdrop)
    }

    @Test
    fun `movie actor dto with null profile creates entity with empty photo`() {
        val dto = MovieActorDto(
            id = 3,
            name = "Actor",
            profilePath = null
        )


        val entity = dto.toEntity(imageSizeSelector)

        val entity = dto.toEntity(imageSizeSelector)


        assertEquals("", entity.photo)
    }

    @Test
    fun `movie list dto with blank release date creates entity with empty year`() {
        val dto = MovieListDto(
            id = 4,
            title = "Title",
            posterPath = null,
            voteAverage = 6.5f,
            voteCount = 100,
            adult = false,
            releaseDate = "",
            genreIds = listOf(1)
        )


        val entity = dto.toEntity(imageSizeSelector)

        val entity = dto.toEntity(imageSizeSelector)


        assertEquals("", entity.year)
    }

    @Test
    fun `movie list dto with malformed release date creates entity with empty year`() {
        val dto = MovieListDto(
            id = 5,
            title = "Title",
            posterPath = null,
            voteAverage = 6.5f,
            voteCount = 100,
            adult = false,
            releaseDate = "2023/01/15",
            genreIds = listOf(1)
        )


        val entity = dto.toEntity(imageSizeSelector)

        val entity = dto.toEntity(imageSizeSelector)


        assertEquals("", entity.year)
    }
}
