package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.remote.MovieListDto
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class MoviesDataMapperTest {

    @Before
    fun setUp() {
        NetworkModule.configApi = Configuration()
        NetworkModule.allGenres = emptyList()
    }

    @Test
    fun `toEntity maps blank release date to empty year`() {
        val entity = createMovieListDto("").toEntity()

        assertEquals("", entity.year)
    }

    @Test
    fun `toEntity maps malformed release date to empty year`() {
        val entity = createMovieListDto("2023/01/15").toEntity()

        assertEquals("", entity.year)
    }

    private fun createMovieListDto(releaseDate: String) = MovieListDto(
        id = 1,
        title = "Title",
        posterPath = null,
        voteAverage = 7.5f,
        voteCount = 123,
        adult = false,
        releaseDate = releaseDate,
        genreIds = emptyList()
    )
}
