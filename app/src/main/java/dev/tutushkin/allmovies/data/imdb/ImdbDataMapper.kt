package dev.tutushkin.allmovies.data.imdb

import dev.tutushkin.allmovies.data.imdb.remote.ImdbMovieDetailDto
import dev.tutushkin.allmovies.data.imdb.remote.ImdbSearchItemDto
import dev.tutushkin.allmovies.data.movies.MoviesDataMapper.UNKNOWN_YEAR
import dev.tutushkin.allmovies.data.movies.local.ActorEntity
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.domain.movies.models.ImdbSearchResult
import kotlin.math.absoluteValue

private const val IMDB_ID_OFFSET = 1_000_000_000
private const val MINIMUM_AGE_NOT_RATED = "NR"

internal fun ImdbSearchItemDto.toDomain(): ImdbSearchResult = ImdbSearchResult(
    imdbId = imdbId,
    title = title,
    year = if (year.equals("N/A", ignoreCase = true)) UNKNOWN_YEAR else year,
    poster = poster.takeUnless { it.equals("N/A", ignoreCase = true) } ?: ""
)

internal fun ImdbMovieDetailDto.toMovieListEntity(): MovieListEntity {
    val movieId = toMovieId()
    return MovieListEntity(
        id = movieId,
        title = title,
        poster = poster.takeUnless { it.equals("N/A", ignoreCase = true) } ?: "",
        ratings = imdbRating.toFloatOrNull() ?: 0f,
        numberOfRatings = imdbVotes.replace(",", "").toIntOrNull() ?: 0,
        minimumAge = rated.takeUnless { it.isBlank() || it.equals("N/A", ignoreCase = true) } ?: MINIMUM_AGE_NOT_RATED,
        year = if (year.equals("N/A", ignoreCase = true)) UNKNOWN_YEAR else year,
        genres = genre
    )
}

internal fun ImdbMovieDetailDto.toMovieDetailsEntity(actorIds: List<Int>): MovieDetailsEntity {
    val movieId = toMovieId()
    return MovieDetailsEntity(
        id = movieId,
        title = title,
        overview = plot,
        backdrop = poster.takeUnless { it.equals("N/A", ignoreCase = true) } ?: "",
        ratings = imdbRating.toFloatOrNull() ?: 0f,
        numberOfRatings = imdbVotes.replace(",", "").toIntOrNull() ?: 0,
        minimumAge = rated.takeUnless { it.isBlank() || it.equals("N/A", ignoreCase = true) } ?: MINIMUM_AGE_NOT_RATED,
        year = if (year.equals("N/A", ignoreCase = true)) UNKNOWN_YEAR else year,
        runtime = runtime.substringBefore(" ").toIntOrNull() ?: 0,
        genres = genre,
        actors = actorIds,
        isActorsLoaded = actorIds.isNotEmpty(),
        directors = director.toDelimitedList(),
        writers = writer.toDelimitedList(),
        languages = language.toDelimitedList(),
        subtitles = language.toDelimitedList(),
        audioTracks = production.toDelimitedList(),
        videoFormats = dvd.toDelimitedList(),
        trailerUrls = website.toDelimitedList()
    )
}

internal fun ImdbMovieDetailDto.toActorEntities(): List<ActorEntity> {
    val movieId = toMovieId()
    return actors.toDelimitedList().map { actorName ->
        val actorId = generateActorId(movieId, actorName)
        ActorEntity(
            id = actorId,
            name = actorName,
            photo = ""
        )
    }
}

internal fun ImdbMovieDetailDto.toMovieId(): Int {
    val digits = imdbId.filter { it.isDigit() }
    val numericId = digits.toLongOrNull() ?: imdbId.hashCode().toLong().absoluteValue
    val withOffset = numericId + IMDB_ID_OFFSET
    val safeValue = if (withOffset > Int.MAX_VALUE) withOffset % Int.MAX_VALUE else withOffset
    return safeValue.toInt()
}

private fun String.toDelimitedList(): List<String> =
    if (isBlank() || equals("N/A", ignoreCase = true)) {
        emptyList()
    } else {
        split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }

private fun generateActorId(movieId: Int, actorName: String): Int {
    val raw = "${movieId}_$actorName".hashCode()
    return if (raw == Int.MIN_VALUE) 0 else raw.absoluteValue
}
